function [hu,hv]=globfilt5(x,y,u,v,action,interpolate)
% function [u,v]=globfilt5(x,y,u,v,action,interpolate)
%
% modified GLOBFILT
% This function is a completely rewritten global histogram operator. It
% now features a graphical input to specify the acceptance interval of
% velocivy vectors. These are plotted in the (u,v) plane and the user
% should specify 4 points, using the left mouse button, that together
% form a 4 sided polygonal region of acceptance.  Alternatively one can
% input a predefined polygon for this. This is specially useful for
% processing large quantities of data. The polygon can be a vector with
% [xvertice yvertice] or a file with the data stored in the same
% way. Such a file can be produced by specifying 'new' for ACTION. Other
% parameters are 'old' or a vector ([xvertice yvertice]).
% Action defaults to 'new' and can be ommited.
% Finally it is possible to specify 'auto' for ACTION leaving the
% validation on automatic. GLOBFILT then uses the mean of the
% velocities plus/minus 2 times the standard deviation as the limits
% for the acceptance area. This option often performs well if the
% vector field is not hevily contaminated with outliers.
% Interpolate defaults to 'off'.
%
% See also MATPIV, MEDIANFILT, MEANFILT, MASK
%
% Alpha ver. 14/4/99 jks

if nargin < 5
  action='new';
end
if nargin < 6
  interpolate='off';
end
mfigure, subplot(211),quiver(x,y,u,v,5)
if ischar(action)==1
  if strcmp(action,'new')
    %mfigure, 
    subplot(212),plot(u,v,'.'), title('scatter plot of velocities')
    xlabel('worldcoordinates per second')
    ylabel('worldcoordinates per second')
    disp('Use left button to mark the 4 corners around your region...')
    hold on
    for i=1:7
      [ii(i),jj(i)]=ginput(1);
      if i>1
	h1=plot([ii(i-1) ii(i)],[jj(i-1) jj(i)],'k-');
	set(h1,'LineWidth',[2]);
      end
    end
    h2=plot([ii(end) ii(1)],[jj(end) jj(1)],'k-');
    set(h2,'LineWidth',[2]);
    drawnow
    glob=[ii(:) jj(:)];
    save globfilt.mat glob
  elseif strcmp(action,'auto')
    usr=1;
    param=3;
    mfigure
    xo=mnanmean(u(:));
    yo=mnanmean(v(:));
    while param~=0,
      sx=param*mnanstd(u(:));
      sy=param*mnanstd(v(:));
      ii=[xo+sx
	xo+sx
	xo-sx
	xo-sx]; 
      jj=[yo+sy
	yo-sy
	yo-sy
	yo+sy];
      mfigure(gcf), plot(u,v,'.'), hold on
      plot(ii,jj,'-'), plot([ii(1) ii(4)],[jj(4) jj(4)],'-')
      hold off
      disp(['Current limit: ',num2str(param),...
	      ' times the standard deviation of U and V'])
      param=input('To change THRESHOLD type new value, \n type 0 to use current value >> ')
    end
    glob=[ii(:) jj(:)];
    save globfilt.mat glob
  elseif strcmp(action,'old')
    D=load('globfilt.mat');
    ii=D.glob(:,1); jj=D.glob(:,2);
  else
    disp('Error! That is not a valid action!')
    return
  end
elseif ischar(action)==0
  ii=action(:,1); jj=action(:,2);
end

prev=isnan(u); previndx=find(prev==1);
%Locate points inside chosen area
in=inpolygon(u,v,ii,jj);
nx=x(~in);
ny=y(~in);
nu=u(~in);
nv=v(~in);

% plot original data if this is the first time with this filter
% e.g. action='new'
scale=2/max(sqrt(u(:).^2+v(:).^2));
if strcmp(action,'new')==1 | strcmp(action,'auto')==1
  mfigure
  vekplot2(x(:).',y(:).',u(:).',v(:).',scale,'b');
  hold on, grid on 
  vekplot2(nx(:).',ny(:).',nu(:).',nv(:).',scale,'r');
  xlabel([num2str(length(nx(:))-length(previndx(:))),' outliers identified by this filter, from totally ', num2str(length(u(:))),' vectors'])
end

%Exclude points outside area
u(~in)=NaN; v(~in)=NaN;
disp([num2str(length(nx(:))-length(previndx(:))),' vectors changed by the global histogram filter'])
%interpolate
if strcmp(interpolate,'on')==1
  disp('Interpolating outliers.....')
  disp('......')
  [u,v]=naninterp(u,v);
end  

hu=u;
hv=v;