function [newm]=dynamask(u,v,dt,wins,imsize,ol,wocofile)
% DYNAMASK - dynamically mask PIV images
%
%[newm]=dynamask(u,v,dt,wins,imsize,ol,wocofile)
%
%
%
if length(wins)==1, wins=[wins wins]; end
if length(wins)>2, disp('Error located between keyboard and chair');return
end
if nargin<7, wocofile='worldco.mat'; end

%assume a mask is present. The last and the two first points in the
%mask define the top/side so they should not be moved. This assumes
%that the mask has been defined counterclockwise.
m=load('polymask.mat');
idx=m.maske.idx(3:end-1);idy=m.maske.idy(3:end-1);
%load world coordinate mapping
w=load(wocofile);
lswo1=w.comap(:,1);lswo2=w.comap(:,2);lswo1(4:6)=[0;0;0];lswo2(4:6)=[0;0;0];
%displacement vector:
ydispl=v*dt/(w.comap(3,2));

% calculate the center of each interrogation window (in pixels)
xpix=wins(2)/2:wins(2)*(1-ol):imsize(2)-wins(2)/2; 
ypix=wins(2)/2:wins(1)*(1-ol):imsize(1)-wins(1)/2;
%sx=length(xpix); sy=length(ypix);
%xpix=repmat(xpix,sy,1);
%ypix=repmat(ypix(:),1,sx);

% calculations
%
% first we locate the velocities at the boundary
inx=isnan(v); 
for i=1:size(inx,2)
  %assume that we have a wave with air above
  tmp=find(inx(:,i)==1);
  xpos=xpix(i);
  ypos=max(tmp)+1;
  tmp2=find( (idx>(xpos-wins(2)/2)) & (idx<(xpos+wins(2)/2)));
  idy(tmp2)=idy(tmp2)+ydispl(ypos,i);
end
newx2=lswo1(1)+ lswo1(2)*idx+ lswo1(3)*idx+...
      lswo1(4)*(idx.*idy)+...
      lswo1(5)*(idx.^2)+lswo1(6)*(idy.^2);
newy2=lswo2(1)+ lswo2(2)*idy+ lswo2(3)*idy+...
      lswo2(4)*(idy.*idx)+...
      lswo2(5)*(idy.^2)+lswo2(6)*(idx.^2); 

m.maske.idx=[m.maske.idx(1:2); idx; m.maske.idx(end)];
m.maske.idy=[m.maske.idy(1:2); idy; m.maske.idy(end)];

m.maske.idxw=[m.maske.idxw(1:2); newx2; m.maske.idxw(end)];
m.maske.idyw=[m.maske.idyw(1:2); newy2; m.maske.idyw(end)];

maske=m.maske;
maske.msk=roipoly([1:imsize(1),1:imsize(2)],maske.idx,maske.idy);
save polymask.mat maske
if nargout~=0
  newm=maske;
end

  




%vv=zeros(size(v)+2); vv(2:end-1,2:end-1)=inx;
%v11=inx-vv(1:end-2,1:end-2); v12=inx-vv(1:end-2,2:end-1);
%v13=inx-vv(1:end-2,3:end);
%v21=inx-vv(2:end-1,1:end-2); v22=inx-vv(2:end-1,2:end-1);
%v23=inx-vv(2:end-1,3:end);
%v31=inx-vv(3:end,1:end-2); v32=inx-vv(3:end,2:end-1);
%v33=inx-vv(3:end,3:end);
%vv=(v11+v12+v13+v21+v22+v23+v31+v32+v33)/9;