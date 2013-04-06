function [bg]=magnitude(x,y,u,v)
%MAGNITUDE plots magnitude of velocity-vectors as background color   
% function [magn]=magnitude(x,y,u,v)
%   
% plots the magnitude of velocity as background color in a plot.
% magnitude(x,y,u) plots U as background color, while
% magnitude(x,y,u,v) plots sqrt(u.^2 + v.^2) as background color.
% magnitude(u) plots U using PCOLOR without x and y axis
% magnitude(u,v) plots  sqrt(u.^2 + v.^2) without x and y-axis
%
% c. 31 july 2000, jks@math.uio.no
%
% for use with MatPIV 1.5

  
% first we check to see if the input data are vectors or
% matrices. This function thus supports plotting of data as output
% from DigImage or VidPIV (which are in vectorform).
% This will only work if the "holes" in the velocity fields are not
% "too big"; meaning that all the x or y values should be present in
% the x and y vectors(!)

if nargin==1
  if ischar(x)
    a=load(x,'ascii');
    x=a(:,1); y=a(:,2); u=a(:,3); v=a(:,4);
    statusen=1;
  elseif isnumeric(x)
    if size(x,2)==4
      x1=x(:,1); y=x(:,2); u=x(:,3); v=x(:,4); clear x
      x=x1; statusen=1;
    end
    statusen==0;
  end
elseif nargin==3
    statusen=0;
end
    
[m,n]=size(x);

if nargin==4 | statusen==1
  if exist('fixdigim.m','file')==2
    if m==1 | n==1
      [x,y,u,v]=fixdigim(x,y,u,v);
    end
  else
    disp('You are plotting data from something other than MatPIV!')
    disp('o - The function FIXDIGIM is missing.');return
  end
end
 


if nargin==1 & statusen==0
    ii=~isnan(x);
    bg=x;
    if nargout==0
        pcolor(bg(ii));
        hold on
        scale=1/max(bg(ii));
        xx= ones(size(x,1),1)*[1:size(x,2)];
        yy= ([1:size(x,1)].')*ones(1,size(x,2));
        vekplot2(xx(ii),yy(ii),x(ii),zeros(size(x(ii))),scale,'w');
        colorbar
    end
elseif nargin==2
    ii=~isnan(x);
    bg=sqrt(x.^2 + y.^2);
    if nargout==0
        pcolor(bg(ii));
        hold on
        scale=1/max(bg(:));
        xx= ones(size(x,1),1)*[1:size(x,2)];
        yy= ([1:size(x,1)].')*ones(1,size(x,2));
        vekplot2(xx(ii),yy(ii),x(ii),y(ii),scale,'w');
        colorbar
    end
elseif nargin==3
    ii=~isnan(u);
    t1=sum(ii); t2=sum(ii');
    ix=find(t1~=0); jy=find(t2~=0);
    bg=u;
    if nargout==0   
        %pcolor(x,y,bg(ii));
        pcolor(x(jy(1):jy(end),ix(1):ix(end)),...
            y(jy(1):jy(end),ix(1):ix(end)),...
            bg(jy(1):jy(end),ix(1):ix(end)));
        hold on
        scale=1/max(abs(u(:)));
        %vekplot2(x(ii),y(ii),u(ii),zeros(size(u(ii))),scale,'w');
        size(zeros(jy(end)-jy(1),ix(end)-ix(1)))
        size(u(jy(1):jy(end),ix(1):ix(end)))
        vekplot2(x(jy(1):jy(end),ix(1):ix(end)),...
            y(jy(1):jy(end),ix(1):ix(end)),...
            u(jy(1):jy(end),ix(1):ix(end)),...
            zeros(jy(end)-jy(1)+1,ix(end)-ix(1)+1),scale,'w');
        colorbar
    end
elseif nargin==4 | (nargin==1 & statusen==1)
    ii=~isnan(u);
    t1=sum(ii); t2=sum(ii');
    ix=find(t1~=0); jy=find(t2~=0);
    bg=sqrt(u.^2 + v.^2);
    if nargout==0
        pcolor(x(jy(1):jy(end),ix(1):ix(end)),...
            y(jy(1):jy(end),ix(1):ix(end)),...
            bg(jy(1):jy(end),ix(1):ix(end)));
        shading flat, hold on
        scale=0.5/max(sqrt(u(ii).^2+v(ii).^2))
        vekplot2(x(jy(1):jy(end),ix(1):ix(end)),...
            y(jy(1):jy(end),ix(1):ix(end)),...
            u(jy(1):jy(end),ix(1):ix(end)),...
            v(jy(1):jy(end),ix(1):ix(end)),scale,'w');
        colorbar
    end
else
    disp('Wrong input argument to MAGNITUDE');
    return
end

if nargout==0
    clear bg
end


