function [x,y,u,v,SnR,Pkh]=multipass2(im1,im2,winsize,Dt,overlap,sensit)

% function [x,y,u,v,snr,pkh]=multipass2(im1,im2,winsize,time,overlap,sensit)
%
% PIV in multiple passes to eliminate the displacement bias.
% Utilizes the increase in S/N by  halving the size of the 
% interrogation windows after the first pass.
% This function finds the displacements in four steps, meaning that
% this is just an extension of the original MULTIPASS file.
%
% See also: 
%          MATPIV, SINGLEPASS, DEFINEWOCO, MULTIPASS
%          PIXEL2WORLD, INTPEAK, MEDIANFILT, INTQUANT
%

% August 1998, J. Kristian Sveen (jks@math.uio.no)
% updated September 1998 JKS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Declarations
counter=1;         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Image read
A=double(imread(im1));
B=double(imread(im2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% First pass to estimate displacement in integer values:
disp('First pass....')
[datax,datay]=firstpass(A,B,winsize,overlap,counter);
%%% Then data validation to remove spurious vectors.
%[datax1,datay1]=medianfilt(datax,datay,sensit,'off','on');
x=ones(size(datax)); y=ones(size(datay)); % need some x and y matrices
for i=1:size(datax,2)
  for j=i:size(datax,1)
    x(j,:)=[1:size(datax,2)];
    y(j,:)=[ones(size(datax,2),1).*(size(datax,1)-j+1)].';
  end
end
disp('...')
[datax1,datay1]=globfilt(x,y,datax,datay,3);
[datax1,datay1]=localfilt(x,y,datax1,datay1,sensit,'median','interp');

clear datax datay x y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expand the velocity data to twice the original size
% This is because we want to use half the interrogation
% window size from now on.
datax=floor(interp2(datax1));
datay=floor(interp2(datay1));
datax(size(datax,1)+1,:)=datax(size(datax,1),:);
datax(:,size(datax,2)+1)=datax(:,size(datax,2));
datay(size(datay,1)+1,:)=datay(size(datay,1),:);
datay(:,size(datay,2)+1)=datay(:,size(datay,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second pass to estimate displacement in integer values:
% now using smaller interrogation windows 
% to utilize the smaller S/N introduced with window offset.
winsize=winsize/2;
disp('Second pass....')
[datax2,datay2]=firstpass(A,B,winsize,overlap,counter,datax,datay);
% Remove spurious vectors
%[datax3,datay3]=medianfilt(datax2,datay2,sensit,'off','on');
x=ones(size(datax2)); y=ones(size(datay2));
for i=1:size(datax2,2)
  for j=i:size(datax2,1)
    x(j,:)=[1:size(datax2,2)];
    y(j,:)=[ones(size(datax2,2),1).*(size(datax2,1)-j+1)].';
  end
end

[datax3,datay3]=globfilt(x,y,datax2,datay2,3);
[datax3,datay3]=localfilt(x,y,datax3,datay3,sensit,'median','interp');
clear datax2 datay2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expand the velocity data to twice the original size
% This is because we want to use half the interrogation
% window size from now on.
datax=floor(interp2(datax3));
datay=floor(interp2(datay3));
datax(size(datax,1)+1,:)=datax(size(datax,1),:);
datax(:,size(datax,2)+1)=datax(:,size(datax,2));
datay(size(datay,1)+1,:)=datay(size(datay,1),:);
datay(:,size(datay,2)+1)=datay(:,size(datay,2));
winsize=winsize/2;
% Third pass to estimate displacement in integer values:
% now using even smaller interrogation windows 
% to utilize the smaller S/N introduced with window offset.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Third pass....')
[datax2,datay2]=firstpass(A,B,winsize,overlap,counter,datax,datay);
% Remove spurious vectors
%[datax3,datay3]=medianfilt(datax2,datay2,sensit,'off','on');
x=ones(size(datax2)); y=ones(size(datay2));
for i=1:size(datax2,2)
  for j=i:size(datax2,1)
    x(j,:)=[1:size(datax2,2)];
    y(j,:)=[ones(size(datax2,2),1).*(size(datax2,1)-j+1)].';
  end
end

[datax3,datay3]=globfilt(x,y,datax2,datay2,3);
[datax3,datay3]=localfilt(x,y,datax3,datay3,sensit,'median','interp');

clear x y datax2 datay2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final pass. Gives displacement to subpixel accuracy.
disp('Final pass......')
[x,y,u,v,SnR,Pkh]=finalpass(A,B,winsize,overlap,round(datax3),round(datay3),Dt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Done............')