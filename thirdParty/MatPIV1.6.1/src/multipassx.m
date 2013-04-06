function [x,y,u,v,SnR,Pkh]=multipassx(im1,im2,wins,Dt,overlap,sensit,maske,iter,datax,datay)

% MULTIPASSX - multiple passes 
% function [x,y,u,v,snr,pkh]=multipassx(im1,im2,winsize,time,...
% overlap,sensit,maske,numofiterations,ustart,vstart)
%
% PIV in multiple passes to eliminate the displacement bias.
% Utilizes the increase in S/N by  halving the size of the 
% interrogation windows after the first pass.
% Sub-function to MATPIV.
%
% See also: 
%          MATPIV, SNRFILT, LOCALFILT, GLOBFILT, DEFINEWOCO

% Copyright 1998-2001, Kristian Sveen, jks@math.uio.no 
% for use with MatPIV 1.6
% Distributed under the terms of the Gnu General Public License manager
% Time stamp: 10:47, Oct 30 2001

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Declarations
counter=1;         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Image read
if ischar(im1)
    [A p1]=imread(im1);
    [B p2]=imread(im2);
    if ~isempty(p1), A=ind2gray(A,p1); end
    if ~isempty(p2), B=ind2gray(B,p2); end
else
    A=uint8(im1); B=uint8(im2);
end
if any([isrgb(A), isrgb(B)])
  A=rgb2gray(A); B=rgb2gray(B);
end

A=double(A); B=double(B);

% background removal added 23. Oct 2002 - testversion
if exist([pwd,'/background.jpg'],'file')==2
    bgim=double(imread('background.jpg'));
    A=A-bgim; B=B-bgim;
    disp('   --> Background removed')
end
% Change October 1, 2002 - added simple image preconditioner:
%[A2,B2]=precondition(A,B);
% Check if preconditioning has made A,B==0. This may happen
% when the images are identical.
%if sum(A2(:))~=0 | sum(B2)~=0
%  A=A2; B=B2; clear A2 B2
%end

%%%%%%%%% First pass to estimate displacement in integer values:
if nargin==6
    maske=''; iter=3;
    %elseif nargin==6
    % maske=[]
    %[datax,datay]=firstpass(A,B,winsize,overlap,counter,[],[]);
end
[sy,sx]=size(A);

if size(wins,1)==1
    if size(wins,2)==1
        wins=[wins, wins];
    end
    for jj=1:iter-2
        wins=[wins; wins(end,:)/2];
    end
end

% check if datax and datay matrixes have correct size
if ~isempty(datax)
  disp(['  ===> Using supplied velocity field as input...with size',num2str(size(datax)),'.'])
  [dy,dx]=size(datax); 
  %winsize in startu and startv matrices
  Wx=floor(sx/dx)/(-overlap+1);  Wy=floor(sy/dy)/(-overlap+1);
  Wi=[1:Wx*(1-overlap):sx-Wx+1];
  Wj=[1:Wy*(1-overlap):sy-Wy+1];
  Si=[1:wins(1,1)*(1-overlap):sy-wins(1,1)+1];
  Sj=[1:wins(1,2)*(1-overlap):sx-wins(1,2)+1];
  datax=round(interp2(Wi,Wj',datax,Si,Sj'));
  datay=round(interp2(Wi,Wj',datay,Si,Sj'));  
  disp(['Interpolated to ',num2str(size(datax))])
  %disp('Method not finished')
  %return

end


for i=1:iter-1
    disp(['* Pass No: ',num2str(i)])
    if i==1 & ~isempty(datax)
        [x,y,datax,datay]=firstpass(A,B,wins(i,:),overlap,counter,[],[],maske);
    else
        [x,y,datax,datay]=firstpass(A,B,wins(i,:),overlap,counter,datax,datay,maske);
    end
    [datax,datay]=globfilt(x,y,datax,datay,3);
    [datax,datay]=localfilt(x,y,datax,datay,sensit,'median',3,maske);
    [datax,datay]=naninterp(datax,datay,'linear',maske,x,y);
    datax=floor(datax); datay=floor(datay);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % expand the velocity data to twice the original size
    if i~=iter-1 
        if wins(i,1)~=wins(i+1,1)    
            X=(1:((1-overlap)*2*wins(i+1,1)):sx-2*wins(i+1,1)+1) + wins(i+1,1);
            XI=(1:((1-overlap)*wins(i+1,1)):sx-wins(i+1,1)+1)+(wins(i+1,1))/2;
        else
            XI=(1:((1-overlap)*wins(i+1,1)):sx-wins(i+1,1)+1)+(wins(i+1,1))/2; X=XI;
        end
        if wins(i,2)~=wins(i+1,2)
            Y=(1:((1-overlap)*2*wins(i+1,2)):sy-2*wins(i+1,2)+1) + wins(i+1,2);
            YI=(1:((1-overlap)*wins(i+1,2)):sy-wins(i+1,2)+1)+(wins(i+1,2))/2; 
        else
            YI=(1:((1-overlap)*wins(i+1,2)):sy-wins(i+1,2)+1)+(wins(i+1,2))/2; Y=YI;
        end
        
        % test 8/12-01
        % $$$ 	if wins(i,2)~=wins(i+1,2)
        % $$$ 	  facx=wins(i,1)/wins(i+1,1);
        % $$$ 	  facy=wins(i,2)/wins(i+1,2);
        % $$$ 	  datax2=zeros(length(XI),length(YI))*nan;
        % $$$ 	  datay2=zeros(length(XI),length(YI))*nan;
        % $$$ 	  datax2(1:facy:end-1,1:facx:end-1)=datax; 
        % $$$ 	  datax2(1:facy:end-1,2:facx:end)=datax;
        % $$$ 	  datax2(2:facy:end,1:facx:end-1)=datax; 
        % $$$ 	  datax2(2:facy:end,2:facx:end)=datax;
        % $$$ 	  datay2(1:facy:end-1,1:facx:end-1)=datay; 
        % $$$ 	  datay2(1:facy:end-1,2:facx:end)=datay;
        % $$$ 	  datay2(2:facy:end,1:facx:end-1)=datay; 
        % $$$ 	  datay2(2:facy:end,2:facx:end)=datay;
        disp('   Expanding velocity-field for next pass')
        datax=round(interp2(X,Y',datax,XI,YI'));
        datay=round(interp2(X,Y',datay,XI,YI'));
        [datax,datay]=naninterp(datax,datay,'linear',maske,...
            repmat(XI,size(datax,1),1),repmat(YI',1,size(datax,2)));
        %figure, imagesc(datax)
        %eval(['save datax_i',num2str(i),'.mat datax datay'])
        %datax=floor(datax2); datay=floor(datay2);
        %else
        datax=round(datax); datay=round(datay);
	
        %end
    end
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final pass. Gives displacement to subpixel accuracy.
disp('* Final Pass')
[x,y,u,v,SnR,Pkh]=finalpass(A,B,wins(end,:),overlap,round(datax),...
			    round(datay),Dt,maske);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
