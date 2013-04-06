function [stat]=automask(ima,wocofile,varargin)
% AUTOMASK - automatically mask images in a PIV timeserie
%
% automask(image,wocofile)
%
% automask(image,wocofile,'display'); % shows the mask in a figure, this
% option can be used in combination with any of the two following:
%
% automask(image,wocofile,'polynom'); % fits a polynomial to the surface
%
% automask(image,wocofile,'rawdata'); % uses the raw surface data - this
% may be more noisy than the ''polynom'' version, but it is also the only
% true representation of the surface. This is the default version if
% omitted.
% 
% The plan is to include other fitting-functions in subsequent versions of
% this file.
%
  
% Version 0.2, for use with MatPIV 1.6
% distributed under the GNU GPL license.
% Copyright J. Kristian Sveen, jks@math.uio.no
%
% Timestamp: 7. jan 2003, 12.40
  
if ischar(ima)
  [A,p1]=imread(ima);
  if isrgb(A), A=rgb2gray(A); end
  if ~isempty(p1), A=ind2gray(A,p1); end  
  if nargin==1, wocofile=''; end
else
  A=ima;
end
oldm=dir('polymask.mat');
if length(oldm)==1
    oldm=load(oldm.name);
else
    oldm=[]; %.maske.idx=[];    oldm.maske.idy=[];
end
if length(varargin)==1 
    [var1]=deal(varargin{:});
    var2=''; var3='';
elseif length(varargin)==2
    [var1,var2]=deal(varargin{:}); var3='';
elseif length(varargin)==3
  [var1,var2,var3]=deal(varargin{:});
else
    var1='rawdata'; var2=''; var3='';
end

if isempty(var2)
    if (~strcmp(var1,'rawdata') & ~strcmp(var1,'polynomial'))
        var2='rawdata';
    end
end
% starting from top right going left counterclockwise
maske.idx=[size(A,2);1];  maske.idy=[1;1];
%[maske.idxw,maske.idyw]=pixel2world(maske.idx,maske.idy,maske.idx,maske.idy,wocofile,'linear');
l=load(wocofile);
lswo1=l.comap(:,1);
lswo2=l.comap(:,2);
lswo1(4:6)=0; lswo2(4:6)=0;
maske.idxw=lswo1(1)+ lswo1(2)*maske.idx+ lswo1(3)*maske.idx+...
    lswo1(4)*(maske.idx.*maske.idy)+...
    lswo1(5)*(maske.idx.^2)+lswo1(6)*(maske.idy.^2);
maske.idyw=lswo2(1)+ lswo2(2)*maske.idy+ lswo2(3)*maske.idy+...
    lswo2(4)*(maske.idy.*maske.idx)+...
    lswo2(5)*(maske.idy.^2)+lswo2(6)*(maske.idx.^2); 
%%%%% Cowens surface locating:
vb=[1 0 -1]; %1 x 3 kernel to do a central difference
K=ones(3,21); %3 x 21 kernel to smooth particles leaving surface

sur=conv2(A,K,'same'); %convolve with K 
[aa bb]=max(sur); %look for maximum in column
[yb,m] = sort(bb); %sort maximum to separate particles from surface
bbb=conv(yb,vb); %look at central difference to find jump point to particles
ind=0;
for iq=1:length(bb)  %find jump point 
  if abs(bbb(iq))<10 %define jump point as a difference of 10 or more
    ind=ind+1;       %in vertical location of a horizontal pixel
    eta(iq)=bb(iq);
  else
    eta(iq)=nan;
  end
end

eta=fillmiss(eta); %surface y coordinates, m is surface x-coordinates

p_coef=polyfit(m,eta,2); %final polynomial fit
% evaluate polynomial at every pixel. 
surf_f=polyval(p_coef,[1:1:length(m)]); 
% subsequently reduce the number of surface points
surf_f=[surf_f(1:10:end)]';

newx=[1:10:length(m)]';
newy=[(eta(1:10:end))]'; 

if any([strcmp(var1,'rawdata'),strcmp(var2,'rawdata')])
    maske.idx=[maske.idx(1:2); newx(:); maske.idx(1)];
    maske.idy=[maske.idy(1:2); newy(:); maske.idy(1)];

    newx2=lswo1(1)+ lswo1(2)*newx+ lswo1(3)*newx+...
        lswo1(4)*(newx.*newy)+...
        lswo1(5)*(newx.^2)+lswo1(6)*(newy.^2);
    newy2=lswo2(1)+ lswo2(2)*newy+ lswo2(3)*newy+...
        lswo2(4)*(newy.*newx)+...
        lswo2(5)*(newy.^2)+lswo2(6)*(newx.^2); 
    maske.idxw=[maske.idxw(1:2); newx2(:); maske.idxw(1)];
    maske.idyw=[maske.idyw(1:2); newy2(:); maske.idyw(1)];
elseif any([strcmp(var1,'polynomial'),strcmp(var2,'polynomial')])
    maske.idx=[maske.idx(1:2); newx(:); maske.idx(1)];
    maske.idy=[maske.idy(1:2); surf_f(:); maske.idy(1)];
  
    newx2=lswo1(1)+ lswo1(2)*newx+ lswo1(3)*newx+...
        lswo1(4)*(newx.*newy)+...
        lswo1(5)*(newx.^2)+lswo1(6)*(newy.^2);
    newy2=lswo2(1)+ lswo2(2)*newy+ lswo2(3)*newy+...
        lswo2(4)*(newy.*newx)+...
        lswo2(5)*(newy.^2)+lswo2(6)*(newx.^2); 
    maske.idxw=[maske.idxw(1:2); newx2(:); maske.idxw(1)];
    maske.idyw=[maske.idyw(1:2); surf_f(:); maske.idyw(1)];  
end
% stretch the outermost points to the edges:
maske.idxw(3)=maske.idxw(2);
maske.idxw(end)=maske.idxw(1);
maske.idx(3)=maske.idx(2);
maske.idx(end)=maske.idx(1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now we compare the mask with the old one (if it exists) and remove points
% in the new mask that are "very" different from the old.
if strcmp(var3,'test')
  if isempty(oldm)
    oldm.maske=maske;
  end

  %%%%%%%%%%%%%%%%%%%%%%HER er feilen
  if length(maske.idy)~=length(oldm.maske.idy)
    %    maske.idy(1:2)=
    %    oldm.maske.idy(3:length(maske.idy)-1)
    test=interp1(oldm.maske.idx(3:end-1),...
		 oldm.maske.idy(3:end-1),maske.idx(3:end));
    oldm.maske.idy=[maske.idy(1:2); test];
    oldm.maske.idx=maske.idx;
    disp('-')
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ny=(maske.idy-oldm.maske.idy).^2;
  ixny=find(ny>100); maske.idy(ixny)=nan;
  maske.idy=fillmiss(maske.idy);
  % now check if the new mask is anywhere near the old one:
  ny=(maske.idy-oldm.maske.idy).^2; ixny=find(ny>100); maske.idy(ixny)=nan;
  if length(ixny)>length(maske.idy)/2
    figure, plot(maske.idy,'.-')
    maske.idy=(maske.idy+oldm.maske.idy)/2;
    disp('WARNING *** WARNING *** WARNING ***')
    disp('Unable to automatically mask this image - use manual method')
    stat=0;
  else
    stat=1;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% roipoly is MUCH faster than the INPOLYGON method used in v0.1 of the
% present code:
maske.msk=roipoly(A,maske.idx,maske.idy);

save polymask.mat maske
  
if any([strcmp(var1,'display'),strcmp(var2,'display')])
    figure
    imagesc(A), hold on
    h1=plot(maske.idx,maske.idy,'wo-'); set(h1,'LineWidth',2);
end




% function [F]=myfit(x,y,xi,fitfunc)
% % subfunction for curvefitting - returns fitting function for use with
% % LSQCURVEFIT
% %
% % should contain
% % 1. sine/cosine
% % 2. Sech^2
% % 3. higher order Stokes expansions
% % 4....
% 
% switch fitfunc
%     case {'sine','sin'}
%         fun = inline('x + y*sin(xdata)','x','y','xdata');
%         F= lsqcurvefit(fun,[2 7], xdata, ydata)
%     case {'cos','cosine'}
%        
%     case {'sech','soliton','sech^2'}
%         
%     case {'stokes','cosn'}
%         
%     otherwise
%         disp('Error located between keyboard and chair')
%         return
% end