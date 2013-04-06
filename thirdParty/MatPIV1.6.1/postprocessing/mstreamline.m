function [h]=mstreamline(x,y,u,v,ds);
% MSTREAMLINE - plot streamlines from velocity field
%
% h=mstreamline(x,y,u,v); attempts to plot the streamlines of a flow
% by using the boundaries as starting points.
%
% The function calls STREAMLINE using the boundaries of the 
% velocityfield as STARTX and STARTY values.
%
% h=mstreamline(x,y,u,v,ds); downsamples the START-vectors by a
% factor ds to display fewer streamlines.
%
% use set(h,'Color','blue') to change the color of the
% streamlines in the figure.
% 
% See also: STREAMLINE
%
% Copyright J. Kristian Sveen, jks@math.uio.no
% Time Stamp: 9. March 2002, 17:51
% For use with MatPIV 1.6 and subsequent versions
 
  
% First we locate the boundaries

if nargin==4
  ds=1;
end

in=find(~isnan(u));

for ii=1:size(u,2)
  iy=find(~isnan(u(:,ii)));
  if ~isempty(iy)
    yy(ii,1:2)=[y(iy(1)+1,ii) y(iy(end)-1,ii)];
    xx(ii,1:2)=[x(iy(1)+1,ii) x(iy(end)-1,ii)];
  else
    yy(ii,1:2)=[nan nan];
    xx(ii,1:2)=[nan nan];
  end
end
yy=[yy(:); y(1,:).'; y(:,1); y(:,end); y(end,:).'];
xx=[xx(:); x(1,:).'; x(:,1); x(:,end); x(end,:).'];
xx=xx(:); yy=yy(:);
xx=xx(1:ds:end); yy=yy(1:ds:end);

% plot the streamlines
h=streamline(x,y,u,v,xx,yy);
set(h,'Color','red');


% clear output if not called.
if nargout==0
  clear
end
