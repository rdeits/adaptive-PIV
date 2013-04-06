function [epsxy,eta]=strain(x,y,u,v,method)
% STRAIN - calculate shear and  normal strain from 2D velocity field
%
% [epsxy,eta]=strain(x,y,u,v,method)
% 
% This function calculates differential quantities from a given
% flowfield  x y u v. METHOD should be one of 'circulation', 
% 'richardson', 'leastsq' or 'centered'. Default is least squares.
% 'centered' uses the MATLAB function CURL.

% Jan 03, 2002
% Copyright Kristian Sveen, jks@math.uio.no
% for use with MatPIV 1.6
% Distributed "as is", under the terms of the GNU general public license

if nargin ==4 | nargin==1
  method='leastsq';
end
if nargin==2 | nargin==1
  if ischar(x)
    if nargin==1
      method='leastsq';
    else
      method=y;
    end
    vel=load(x);
    x=vel(:,1); y=vel(:,2); u=vel(:,3); v=vel(:,4);
  else
    disp('Wrong input to STRAIN');
    return
  end
end

if size(x,2)==1
  disp('Converting vectors to matrices')
  [x,y,u,v]=fixdigim(x,y,u,v);
end

% SCALE is the scale for velocity vectors.
scale=0.1/max(sqrt(u(:).^2 + v(:).^2));

DeltaX=x(1,2)-x(1,1);
DeltaY=y(1,1)-y(2,1);

if strcmp(method,'circulation')==1
    Dx=(1/(8*DeltaX)).*[-1 0 1
        -2 0 2
        -1 0 1];
    Dy=(1/(8*DeltaY)).*[1 2 1
        0 0 0
        -1 -2 -1];  
    epsxy=conv2(v,Dx,'valid')+conv2(u,Dy,'valid');
    eta=conv2(v,Dy,'valid')+conv2(u,Dx,'valid');
    epsxy=-real(epsxy);
    eta=real(eta);
    xa=x(2:end-1,2:end-1);
    ya=y(2:end-1,2:end-1);
    
elseif strcmp(method,'richardson')==1
    for i=3:1:size(x,2)-2
        for j=3:1:size(x,1)-2
            epsxy(j-2,i-2)= -(-v(j,i+2) +8*v(j,i+1) -8*v(j,i-1) +v(j,i-2))/(12*DeltaX)...
                - (-u(j+2,i) +8*u(j+1,i) -8*u(j-1,i) +u(j-2,i))/(12*DeltaY);
            eta(j-2,i-2)= (-v(j,i+2) +8*v(j,i+1) -8*v(j,i-1) +v(j,i-2))/(12*DeltaY)...
                + (-u(j+2,i) +8*u(j+1,i) -8*u(j-1,i) +u(j-2,i))/(12*DeltaX);
        end
    end
    
    xa=x(3:end-2,3:end-2);
    ya=y(3:end-2,3:end-2);
    
elseif strcmp(method,'leastsq')==1
    for i=3:1:size(x,2)-2
        for j=3:1:size(x,1)-2
            epsxy(j-2,i-2)= -(2*v(j,i+2) +v(j,i+1) -v(j,i-1) -2*v(j,i-2))/(10*DeltaX)...
                - (2*u(j+2,i) +u(j+1,i) -u(j-1,i) -2*u(j-2,i))/(10*DeltaY);
            eta(j-2,i-2)= (2*v(j,i+2) +v(j,i+1) -v(j,i-1) -2*v(j,i-2))/(10*DeltaY)...
                + (2*u(j+2,i) +u(j+1,i) -u(j-1,i) -2*u(j-2,i))/(10*DeltaX);
        end
    end
    
    xa=x(3:end-2,3:end-2);
    ya=y(3:end-2,3:end-2);
elseif strcmp(method,'centered')==1 & exist('divergence','file')==2
    eta=-divergence(x,y,u,v);
    epsxy=divergence(x,y,v,u);
    xa=x(1,:);ya=y(:,1);
else
    disp([method,' is not a valid calculation method!!!'])
    disp(['Check your spelling or that you have the function ',...
            'CURL in your path']);
    return
end

if nargout==0
    %plot the stuff if no output argument is specified
    figure
    subplot(2,1,1)
    pcolor(xa,ya,epsxy); ax=axis;
    hold on
    shading interp, colormap(hot), caxis([-30 30]), colorbar
    vekplot2(x(:).',y(:).',u(:).',v(:).',scale,'b');
    axis(ax)
    subplot(2,1,2)
    pcolor(xa,ya,eta);
    hold on
    shading interp, caxis([-30 30]), colorbar
    vekplot2(x(:).',y(:).',u(:).',v(:).',scale,'b');
    axis(ax)
    % clear memory to avoid outputing the result to the screen.
    clear
    
    %else
   % omega=outp;
end
