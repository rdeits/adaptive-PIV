function [xi, yi, iu, iv, D] = piv_mqd( im1, im2, ...
			     nx_pixel, ny_pixel, ...
			     overlap_x, overlap_y, ...
			     iu_max, iv_max, ...
			     i_mode )
%========================================================================
%
% version 1.00
%
%
% 	piv_mqd.m
%
%
% Description:
%
%	To calculate PIV displacement using MQD method.
%	This program is to be called by the main program 'mpiv.m'
%
%	  - simple MQD algorism
%	  - search close to image edge
%	  - Gaussian subpixel fit
%	  - output MQD result
%
%	Requires
%	  - func_findpeak2.m
%	  - func_pivwindowsize.m
%
% Variables:
%
%  Input:
%	im1 and 2	image files (double precision)
%	nx_pixel	subwindow size in x
%			(should be larger than 20, typical 32 or 64)
%	ny_pixel	subwindow size in y
%			(should be larger than 20, typical 32 or 64)
%	overlap_x	overlap ratio of adjacent subwindows in x
%	overlap_y	overlap ratio of adjacent subwindows in y
%	iu_max		maximum displacement in x (unit: pixel)
%	iv_max		maximum displacement in y (unit: pixel)
%			-> iu_max and iv_max give search area
%	i_mode          = 0: no double check
%			= 1: with double check
%
%  Output:
%	xi, yi		location of velocity vector
%	iu, iv		velocity vector
%	D		maximum value of image intensity difference
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
%=======================================================================
%
% Update:
%       1.01    2009/07/01 BSD License applied
%	1.00	2003/07/01 double check option i_mode has been added.
%	0.98	2003/07/01 func_findpeak2.m and def. of SNR have been changed.
%       0.97    2003/06/11 Code has been refined
%       0.96    2003/06/10 Simplified some sentences by KAC
%       0.95    2003/06/10 Simplified some sentences by KAC
%                          Comments has been refined by KAC
%	0.94	2003/04/07 peak search routine has been modified
%	0.93	2003/04/03 output MQD matrix routine has been inserted
%	0.92	2003/04/02 peak search routine has been modified
%	0.91	2003/04/02 initial setup has been modified
%	0.90	2002/12/04 simplified algorism
%	0.21	2002/10/21 bug fixed for MQD loop
%	0.20	2002/10/09 bug fixed for MQD loop
%	0.10	2002/09/12 add subpixel analysis
%	0.01	2002/09/11 First version
%
%========================================================================

%
% <===== Input for professional use				<=====
%      can be replaced with other appropriate values

% i_plot = 1        check plotting
%        = other    no plotting
i_plot = 9  ;

% set filter to eliminate stray vectors: 1-std, 2-median
i_filter = 2;

% Set threshold value (times of standard deviation) 
% Vectors will be eliminated if exceeded
vec_std = 3.0;

% set interpolation of missing vector	: 1-linear, 2-spline, 3-kriging
i_interp = 3;

% SNR: signal to noise ratio to find peak
r_SNR = 3.0;

% r_peak: ratio of maximum and mean
r_MMR = 1.10;

% r_peak: ratio of 1st peak and 2nd peak
r_PPR = 1.05;

% set area of search
p_search = 1/3; 			% percentage of subwindow

% min and max values for MQD
d_min      = 10^(-5);
d_max      = Inf;

% =====> End of input for professional use			======>

%
% --- check for plotting
%

disp('-> PIV method using MQD algorism with Gaussian subpixel fit')

%
% --- initialization
%

nx = size(im1,1);
ny = size(im1,2);

% define search area
if ( iu_max <= 0 ) | ( iv_max <= 0 ) 
  % area of search defined by 1/3 rule
  nx_movemax = ceil( p_search*nx_pixel );
  ny_movemax = ceil( p_search*ny_pixel );
else
  % area of search defined by iu_max and iv_max
  nx_movemax = floor( iu_max );
  ny_movemax = floor( iv_max );
  if nx_movemax >= nx_pixel
     nx_movemax = nx_pixel;
  end
  if ny_movemax >= ny_pixel
     ny_movemax = ny_pixel;
  end
end

nx_search  = 2*nx_movemax + 1;
ny_search  = 2*ny_movemax + 1;

% to obtain the center locations of all the subwindows
%   (dx_center and dy_center)
[ xi, yi, nx_start, ny_start, nx_overlap, ny_overlap, dx_center, dy_center ] ...
    = func_pivwindowsize( 'mqd', nx, ny, nx_pixel, ny_pixel, overlap_x, overlap_y );

% number of vectors in x and y
mx = max(size(xi));
my = max(size(yi));

c_tmp = strcat( 'Total number of vectors = ', ...
		int2str(mx),' x  ', int2str(my) );
disp( c_tmp );

%
% --- main routine
%

for iy = 1: my

  c_proc = strcat( 'process accomplished :  ', ...
		   num2str( 100*(iy-1)/(my-1),' %03.0f' ), '/100' );
  disp( c_proc )

  for ix = 1: mx

    % create target window from 1st image
    % area of target subwindow
    ix1 = xi(ix) - dx_center;
    ix2 = ix1 + nx_pixel - 1;
    iy1 = yi(iy) - dy_center;
    iy2 = iy1 + ny_pixel - 1;

    % center of target window
    ix_center = ( ix1 - 1 + dx_center );
    iy_center = ( iy1 - 1 + dy_center );

    f1 = im1( ix1:ix2, iy1:iy2 );

%
% --- calculation uisng MQD
%

    C = zeros(nx_search,ny_search);

    isy = 0;
    for jy = -ny_movemax : ny_movemax
      isx = 0;
      isy = isy + 1;
      
      for jx = -nx_movemax : nx_movemax
        isx = isx + 1;

%
% --- create search subwindow in 2nd image
%
        f2 = zeros(nx_pixel,ny_pixel);

        kx1 = ix1 + jx;
        kx2 = kx1 + nx_pixel - 1;
        ky1 = iy1 + jy;
        ky2 = ky1 + ny_pixel - 1;

        if ( kx1 >= 1 ) & ( kx2 <= nx ) & ( ky1 >= 1 ) & ( ky2 <= ny ) 

           f2 = im2( kx1:kx2, ky1:ky2 );
           n  = size(im2,1)*size(im2,2);
              
	   d = sum( sum( abs(f1 - f2) ) )/n;

	   if d ~= 0
  	     C(isx,isy) = d;
           else
    	     C(isx,isy) = d_min;
           end

	else
    	  C(isx,isy) = d_max;
        end

      end
    end

%
% --- peak finding
%

    C = 1./C;
    ncx = size(C,1);
    ncy = size(C,2);

    % fill missing data in C using linear interpolation
    %if max(max(isnan(C))) ~= 0
    %  [ C ] = vector_interp_linear( C );
    %end

    [ ip_x, ip_y, SNR, MMR, PPR ] = func_findpeak2( C, -2 );

    % find relative position of peak
    % v1.00
    if rem(ncx,2) == 0
      ix_peak = ip_x - (ncx/2+0.5);
    else
      ix_peak = ip_x - ceil(ncx/2);
    end
    if rem(ncy,2) == 0
      iy_peak = ip_y - (ncy/2+0.5);
    else
      iy_peak = ip_y - ceil(ncy/2);
    end

    if i_plot == 1
      figure(1);clf;
      colormap(jet)
      %contour( C', 25 );
      surf(C');
      hold on
        plot( ip_x, ip_y, 'bo', ...
	         'MarkerSize', 8, ...
	         'MarkerFaceColor', 'b', ...
	         'MarkerEdgeColor', 'k' );
      hold off
      disp( '-> push key' )
      pause
    end

%
% --- eliminate vectors with small SNR ratio in correlation
%

    %if SNR < r_SNR | PPR < r_PPR 
    if MMR < r_MMR | PPR < r_PPR 
      ix_peak = NaN;
      iy_peak = NaN;
    end

%
% --- eliminate vectors in large displacement with iu_max and iv_max
%

    if abs(ix_peak) >= iu_max
      ix_peak = NaN;
      iy_peak = NaN;
    end
    if abs(iy_peak) >= iv_max
      ix_peak = NaN;
      iy_peak = NaN;
    end

%
% --- end of main loop
%

    is_x(ix,iy) = ix_peak;
    is_y(ix,iy) = iy_peak;

  end
end 

%
% --- post process or second velocity field estimation with same window size
%

if i_mode == 1

  disp('> ' );
  disp('> Double checking velocity vector for same windiow size' );
  n_scale = 1;
  [xi,yi,iu,iv] = piv_mrs( im1, im2, ... 
			   xi, yi, is_x, is_y, ...
			   nx_pixel, ny_pixel, n_scale, ...
                           overlap_x, overlap_y, ...
			   iu_max, iv_max, ...
			   i_filter, vec_std, i_interp, ...
			   1, 1 );
else

  iu = is_x;
  iv = is_y;

end
