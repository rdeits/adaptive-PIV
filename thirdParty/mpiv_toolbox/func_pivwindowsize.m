function [ xi, yi, nx_start, ny_start, nx_overlap, ny_overlap, dxc, dyc ] ...
    = func_pivwindowsize( piv_type, ...
			  nx, ny, nx_pixel, ny_pixel, ...
			  overlap_x, overlap_y );
%========================================================================
%
% version 0.30
%
%
%       func_pivwindowsize.m
%
%
% Description:
%
%       This program is to determine the locations of all the piv velocity vectors.
%
% Variables:
%
%  Input:
%   nx and xy   size of images in x and y
%	nx_pixel	subwindow size in x
%	ny_pixel	subwindow size in y
%
%  Output:
%   xi and yi   locations of vectors
%     (nx_start and ny_start - not used
%      nx_overlap and ny_overlap - not used
%      dxc and dyc - not used)
%
%======================================================================
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
%========================================================================
%
% Update:
%       0.31    2009/07/01 BSD License applied
%       0.30    2002/06/12 Refined
%       0.20    2002/06/11 Refined
%       0.10    2002/04/02 firt version
%
%========================================================================

%
% <===== Input for professional use				<=====
%      can be replaced with other appropriate values

% distrance from the image edge divided by window size
n_r = 1/4;

% =====> End of input for professional use			======>


% center location of subwindow
if rem(nx_pixel, 2) == 0
  dxc = nx_pixel/2 + 0.5;
else
  dxc = nx_pixel/2;
end

if rem(ny_pixel, 2) == 0
  dyc = ny_pixel/2 + 0.5;
else
  dyc = ny_pixel/2;
end

% overlap of subwindow in pixel
nx_overlap = floor( nx_pixel*overlap_x );
ny_overlap = floor( ny_pixel*overlap_y );

% starting pixel point
if piv_type == 'mqd'
  nx_start = nx_pixel*n_r;
  ny_start = ny_pixel*n_r;
else
  nx_start = 1;
  ny_start = 1;
end

% number of vectors
mx = ceil( ((nx-2*nx_start)-(nx_pixel-nx_overlap))/(nx_pixel-nx_overlap) ) + 1;
my = ceil( ((ny-2*ny_start)-(ny_pixel-ny_overlap))/(ny_pixel-ny_overlap) ) + 1;

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
while xi(mx) >= nx -1 - ceil(nx_pixel/2);
  xi = xi(1:mx-1);
  mx = mx - 1;
end

while yi(my) >= ny -1 - ceil(ny_pixel/2);
  yi = yi(1:my-1);
  my = my - 1;
end
