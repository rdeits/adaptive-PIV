function [hu,hv]=globfilt(x,y,u,v,varargin)

% function [u,v]=globfilt(x,y,u,v,actions)
%
% This function is a so called global histogram operator. It
% features a few slightly different ways of giving the maximum and
% minimum velocities allowed in your vector fields.
%
% There are two basically different methods used in GLOBFILT, The first
% uses a graphical input to specify the acceptance interval of velocity
% vectors. These are plotted in the (u,v) plane and the user should
% specify 4 points, using the left mouse button, that together form a 4
% sided polygonal region of acceptance. Use 'manual' as input parameter
% for this option.  Alternatively one can make an acception interval
% based on the standard deviations (x and y) of the measurement
% ensemble. This can be done in three different ways, namely 1) by
% specifying a factor (a number), 2) by specifying 'loop' or 3) by
% specifying a vector with the upper and lower velocitylimits. In the
% former case GLOBFILT uses the mean of the velocities plus/minus the
% number times the standard deviation as the limits for the acceptance
% area. In the second case GLOBFILT loops and lets the user
% interactively set the factor. This option often performs well if the
% vector field is not heavily contaminated with outliers. The third
% option is used by specifying an input vector [Umin Umax Vmin Vmax]
% which defines the upper and lower limits for the velocities.
%
% Additionally you can include 'interp' as a final input to
% interpolate the outliers found by GLOBFILT.
%
% See also MATPIV, SNRFILT, LOCALFILT, MASK

% 1999 -2004 copyright J.K.Sveen jks@math.uio.no
% Dept. of Mathematics, Mechanics Division, University of Oslo, Norway
%
% For use with MatPIV 1.6.1
% Distributed under the Gnu General Public License

if nargin < 5
  disp('Not enough input arguments!'); return
end
tm=cellfun('isclass',varargin,'double');
pa=find(tm==1);
if length(pa)>1
  disp('Only one numeric input allowed!'); return
end
fprintf(' Global filter running - ')
if max(sqrt(u(:).^2+v(:).^2))~=0
  scale=2/max(sqrt(u(:).^2+v(:).^2));
else
  scale=0.1;
end
if any(strcmp(varargin,'manual')) & ~any(strcmp(varargin,'loop'))
  figure, subplot(211),vekplot2(x,y,u,v,scale);
  subplot(212),plot(u,v,'.'), title('scatter plot of velocities')
  xlabel('worldcoordinates per second')
  ylabel('worldcoordinates per second')
  disp('Use left button to mark the 4 corners around your region...')
  hold on
  for i=1:4
    [ii(i),jj(i)]=ginput(1);
    if i>1
      h1=plot([ii(i-1) ii(i)],[jj(i-1) jj(i)],'k-');
      set(h1,'LineWidth',[2]);
    end
  end
  h2=plot([ii(4) ii(1)],[jj(4) jj(1)],'k-');
  set(h2,'LineWidth',[2]); 
  clear in; in=inpolygon(u,v,ii,jj);
  subplot(211), hold on
  vekplot2(x,y,u,v,scale,'b');
  vekplot2(x(~in),y(~in),u(~in),v(~in),scale,'r');
  drawnow
elseif any(strcmp(varargin,'loop')) & ~any(strcmp(varargin,'manual'))
  usr=1;
  if ~isempty(pa)
    param=cat(1,varargin{pa});
    %param=cell2mat(varargin(pa));
  else
    param=3; 
    disp('Warning! no threshold specified. Using standard setting.')
  end
  xo=mnanmean(u(:)); yo=mnanmean(v(:));
  while param~=0,
      sx=param*mnanstd(u(:)); sy=param*mnanstd(v(:));
      if ~any(strcmp(varargin,'circle'))   
          ii=[xo+sx; xo+sx; xo-sx; xo-sx]; 
          jj=[yo+sy; yo-sy; yo-sy; yo+sy];
      else
          ttt=0:0.1:2*pi;
          ii=xo+sx*sin(ttt); jj=yo+sy*cos(ttt); ii=ii(:); jj=jj(:);
      end
          figure(gcf), subplot(211),vekplot2(x,y,u,v,scale);
          subplot(212), plot(u,v,'.'), hold on, plot(ii,jj,'-') 
          plot([ii(1) ii(4)],[jj(4) jj(4)],'-'),  hold off
          clear in; in=inpolygon(u,v,ii,jj);
          subplot(211), hold on
          vekplot2(x,y,u,v,scale,'b');
          vekplot2(x(~in),y(~in),u(~in),v(~in),scale,'r');
          fprintf(['with limit: ',num2str(param),...
                  ' *std [U V]'])
          param=input(['To change THRESHOLD type new value, \n type 0 to use current value >> ']);
         
  end
  close
elseif any(cellfun('isclass',varargin,'double')==1)& ~any(strcmp(varargin,'loop')) 
  param=cat(1,varargin{pa});
  %param=cell2mat(varargin(pa));
  if length(param)==1
    sx=param*mnanstd(u(:)); sy=param*mnanstd(v(:));
    xo=mnanmean(u(:)); yo=mnanmean(v(:));
    if ~any(strcmp(varargin,'circle'))  
        ii=[xo+sx; xo+sx; xo-sx; xo-sx]; 
        jj=[yo+sy; yo-sy; yo-sy; yo+sy];
    else
        ttt=0:0.1:2*pi;
        ii=xo+sx*sin(ttt); jj=yo+sy*cos(ttt); ii=ii(:); jj=jj(:);
    end
    fprintf(['with limit: ',num2str(param),...
            ' *std [U V]'])
    %close
  elseif length(param)==4
    sx(1)=param(1); sy(1)=param(3);
    sx(2)=param(2); sy(2)=param(4);
    ii=[sx(1); sx(2); sx(2); sx(1)]; 
    jj=[sy(1); sy(1); sy(2); sy(2)];
    fprintf(['Current limit: [',num2str(param),'] = (umin,umax,vmin,vmax)'])    
  else
    fprintf('Something wrong with your numerical input')
  end
else
  disp('Error! Check your input to GLOBFILT')
  %close
  return
end
prev=isnan(u); previndx=find(prev==1);
%Locate points inside chosen area
in=inpolygon(u,v,ii,jj);
nx=x(~in); ny=y(~in);
nu=u(~in); nv=v(~in);

%scale=3/max(sqrt(u(:).^2+v(:).^2));
if any(strcmp(varargin,'manual')==1) | any(strcmp(varargin,'loop')==1)
  figure, vekplot2(x(:).',y(:).',u(:).',v(:).',scale,'b');
  hold on, grid on 
  vekplot2(nx(:).',ny(:).',nu(:).',nv(:).',scale,'r');
  xlabel([num2str(length(nx(:))-length(previndx(:))),...
	  ' outliers identified by this filter, from totally ',...
	  num2str(length(u(:))),' vectors'])
end
%Exclude points outside area
u(~in)=NaN; v(~in)=NaN;
%interpolate
if any(strcmp(varargin,'interp')==1)
  if any(isnan(u(:)))
    [u,v]=naninterp2(u,v);
    vekplot2(x,y,u,v,scale,'g');
    title('Green arrows are validated and interpolated vector field')
  end  
end
fprintf([' ..... ',num2str(length(nx(:))-length(previndx(:))),...
      ' vectors changed\n'])
hu=u; hv=v;
