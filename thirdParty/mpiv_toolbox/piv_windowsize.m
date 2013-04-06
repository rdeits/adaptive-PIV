function [ xi,yi, nx_start,ny_start, nx_overlap,ny_overlap, dxc,dyc ] = piv_windowsize( nx,ny, nx_pixel,ny_pixel, overlap_x,overlap_y );
%========================================================================
%
% version 0.10
%
%
%       piv_windowsize.m
%
%
% Description:
%
%       Determine piv vector location
%       + Specific
%
% Variables:
%
%       Input;
%
%       Output;
%
%======================================================================
%
% Terms:
%
%       Distributed under the terms of the terms of the BSD License
%
% Copyright:
%
%       Nobuhito Mori
%           Disaster Prevention Research Institue
%           Kyoto University, JAPAN
%           mori@oceanwave.jp
%
%======================================================================
%
% Update:
%       0.11    2009/07/01 BSD License applied
%       0.10    2002/04/02 firt version
%
%======================================================================

% center location of window
if rem(nx_pixel,2) == 0
  dxc = nx_pixel/2 + 0.5;
else
  dxc = ceil(nx_pixel/2);
end
if rem(ny_pixel,2) == 0
  dyc = ny_pixel/2 + 0.5;
else
  dyc = ceil(ny_pixel/2);
end

% overlap pixel size
nx_overlap = floor( nx_pixel*overlap_x );
ny_overlap = floor( ny_pixel*overlap_y );

% start pixel point
nx_start   = nx_pixel/4;
ny_start   = ny_pixel/4;

% number of vector
mx = floor( ((nx-2*nx_start)-(nx_pixel-nx_overlap))/(nx_pixel-nx_overlap) ) ;
my = floor( ((ny-2*ny_start)-(ny_pixel-ny_overlap))/(ny_pixel-ny_overlap) ) ;

% set vector location
for ix = 1: mx
  % origin of x location of target windownx
  ix1       = nx_start + (nx_pixel - nx_overlap)*(ix-1) + 1;
  % center of target window
  xi(ix)    = ( ix1 - 1 + dxc );
end
for iy = 1: my
  % origin of y location of target window
  iy1       = ny_start + (ny_pixel - ny_overlap)*(iy-1) + 1;
  % center of target window
  yi(iy)    = ( iy1 - 1 + dyc );
end

% check xi and yi
if xi(mx) >= nx -1 - ceil(nx_pixel/2);
   xi = xi(1:mx-1);
elseif xi(mx) + ceil(nx_pixel/2) <= nx;
end
if yi(my) >= ny -1 - ceil(ny_pixel/2);
   yi = yi(1:my-1);
end
