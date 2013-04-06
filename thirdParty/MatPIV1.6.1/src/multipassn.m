function [x,y,u,v,SnR,Pkh]=multipassn(im1,im2,winsize,Dt,overlap,sensit,maske)

% function [x,y,u,v,snr,pkh]=multipassn(im1,im2,winsize,time,overlap,sensit,maske)
%
% PIV in multiple passes to eliminate the displacement bias.
% Utilizes the increase in S/N by  halving the size of the 
% interrogation windows after the first pass.
% Sub-function to MATPIV.
%
% See also: 
%          MATPIV, SNRFILT, LOCALFILT, GLOBFILT, DEFINEWOCO
%          
% 

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
else
  p1=[]; p2=[];
end

if any([isrgb(A), isrgb(B)])
  A=rgb2gray(A); B=rgb2gray(B);
end

if ~isempty(p1), A=ind2gray(A,p1); end
if ~isempty(p2), B=ind2gray(B,p2); end

A=double(A); B=double(B);
%%%%%%%%% First pass to estimate displacement in integer values:
if nargin==6
    maske=''; 
    %elseif nargin==6
    % maske=[]
    %[datax,datay]=firstpass(A,B,winsize,overlap,counter,[],[]);
end
disp('* First Pass')
[x,y,datax,datay]=firstpass(A,B,winsize,overlap,counter,[],[],maske);

[datax1,datay1]=globfilt(x,y,datax,datay,3);
[datax1,datay1]=localfilt(x,y,datax1,datay1,sensit,'median',3,maske);
[datax1,datay1]=naninterp(datax1,datay1,'linear',maske,x,y);

clear datax datay x y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expand the velocity data to twice the original size
% This is because we want to use half the interrogation
% window size from now on.
winsize=winsize/2;
[sy,sx]=size(A);
X=(1:((1-overlap)*2*winsize):sx-2*winsize+1)+(2*winsize)/2;
Y=(1:((1-overlap)*2*winsize):sy-2*winsize+1)+(2*winsize)/2;
XI=(1:((1-overlap)*winsize):sx-winsize+1)+(winsize)/2;
YI=(1:((1-overlap)*winsize):sy-winsize+1)+(winsize)/2; 
datax=interp2(X,Y',datax1,XI,YI');
datay=interp2(X,Y',datay1,XI,YI');
[datax,datay]=naninterp(datax,datay,'linear',maske,...
    repmat(XI,size(datax,1),1),repmat(YI',1,size(datax,2)));
datax=floor(datax); datay=floor(datay);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second pass to estimate displacement in integer values:
% now using smaller interrogation windows 
% to utilize the smaller S/N introduced with window offset.
disp('* Second Pass')
[x,y,datax2,datay2]=firstpass(A,B,winsize,overlap,counter,datax,datay,maske);
[datax3,datay3]=globfilt(x,y,datax2,datay2,3);
[datax3,datay3]=localfilt(x,y,datax3,datay3,sensit,'median',3,maske);
[datax1,datay1]=naninterp(datax3,datay3,'linear',maske,x,y);

clear datax datay x y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expand the velocity data to twice the original size
% This is because we want to use half the interrogation
% window size from now on.
winsize=winsize/2;

X=(1:((1-overlap)*2*winsize):sx-2*winsize+1)+(2*winsize)/2;
Y=(1:((1-overlap)*2*winsize):sy-2*winsize+1)+(2*winsize)/2;
XI=(1:((1-overlap)*winsize):sx-winsize+1)+(winsize)/2;
YI=(1:((1-overlap)*winsize):sy-winsize+1)+(winsize)/2; 
datax=interp2(X,Y',datax1,XI,YI');
datay=interp2(X,Y',datay1,XI,YI');
[datax,datay]=naninterp(datax,datay,'linear',maske,...
    repmat(XI,size(datax,1),1),repmat(YI',1,size(datax,2)));
datax=floor(datax); datay=floor(datay);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Third pass to estimate displacement in integer values:
% now using smaller interrogation windows 
% to utilize the smaller S/N introduced with window offset.
disp('* Third Pass')
[x,y,datax2,datay2]=firstpass(A,B,winsize,overlap,counter,datax,datay,maske);
[datax3,datay3]=globfilt(x,y,datax2,datay2,3);
[datax3,datay3]=localfilt(x,y,datax3,datay3,sensit,'median',3,maske);
[datax1,datay1]=naninterp(datax3,datay3,'linear',maske,x,y);

clear x y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final pass. Gives displacement to subpixel accuracy.
disp('* Fourth and final Pass')
[x,y,u,v,SnR,Pkh]=finalpass(A,B,winsize,overlap,round(datax1),...
			    round(datay1),Dt,maske);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
