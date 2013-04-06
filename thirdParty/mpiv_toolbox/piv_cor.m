function [xi, yi, iu, iv] = piv_cor( im1, im2, ...
			     nx_pixel, ny_pixel, ...
			     overlap_x, overlap_y, ...
			     iu_max, iv_max, ...
			     i_mode )
%========================================================================
%
% version 0.74
%
%
% 	piv_cor.m
%
%
% Description:
%
%	Calculate velocity by PIV method with correlation function.
%	This program is called by 'mpiv.m' and 'piv_crr.m'
%
%	  - Correlation algorism
%	  - search close to image edge
%	  - Gaussian subpixel fit
%
%	Requires
%	  - func_findpeak2.m
%	  - func_pivwindowsize.m
%
% Variables:
%
%	Input:
%	imr1 and 2	image files (double precision)
%	nx_pixel	subwindow size in x 
%			(should be larger than 20, typical 32 or 64)
%	ny_pixel	subwindow size in x 
%			(should be larger than 20, typical 32 or 64)
%	overlap_x	overlap ratio of adjacent subwindows in x 
%			(typically 0.0 or 0.5)
%	overlap_y	overlap ratio of adjacent subwindow in y
%	iu_max		maximum displacement in x (unit: pixel)
%	iv_max		maximum displacement in y (unit: pixel)
%			-> iu_max and iv_max give search area
%	i_mode          = 0: no double check
%			= 1: with double check
%
%	Output:
%	xi, yi		location of velocity vector
%	iu, iv		velocity vector
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
%========================================================================
%
% Update:
%       0.75    2009/07/01 BSD License applied
%	0.74	2003/07/01 func_findpeak2.m and def. of SNR have been changed.
%	0.73	2003/06/26 input parameter i_opt has been replaced by i_mode
%	0.72	2003/06/23 PPR has been added.
%	0.70	2003/06/23 double check option i_mode has been added.
%	0.66	2003/06/23 xcorr2_fast has been inserted
%	0.65	2003/06/20 normxcorr2 has been replaced by xcorr2
%       0.62    2003/06/12 Minor modification
%       0.60    2003/06/11 Moving window has been eliminated
%       0.51    2003/06/11 Code has been refined
%	0.50	2003/06/10 Simplified version (corr2) has been updated by KAC
%			   Comments has been refined by KAC
%	0.10	2003/04/02 initial setup has been modified
%	0.01	2002/12/04 First version
%
%========================================================================

%
% <===== Input for professional use				<=====
%      can be replaced with other appropriate values

% i_plot = 1    ; test plot 
%        = other; no plot
i_plot = 9;

% set filter to eliminate stray vectors: 1-std, 2-median
i_filter = 2;

% Set threshold value (times of standard deviation) 
% Vectors will be eliminated if exceeded
vec_std = 1.5;

% set interpolation of missing vector	: 1-linear, 2-spline, 3-kriging
i_interp = 3;

% SNR: signal to noise ratio to find peak
r_SNR  = 3.00;

% r_peak: ratio of 1st peak and 2nd peak
r_PPR = 1.10;

% set area of search
p_search = 1/3; 			% percentage of subwindow

% =====> End of input for professional use			======>

%
% --- check options for subpixel fit
%

disp('> PIV using correlation algorism with Gaussian subpixel fit')

%
% --- initialization
%

nx = size(im1,1);
ny = size(im1,2);

% maximum space lag in correlation function
lx_pixel = ceil(p_search*nx_pixel);
ly_pixel = ceil(p_search*ny_pixel);

% to obtain the center locations of all the subwindows
%   (dx_center and dy_center)
[ xi, yi, nx_start, ny_start, nx_overlap, ny_overlap, dx_center, dy_center ] ...
    = func_pivwindowsize( 'cor', ...
			  nx, ny, nx_pixel, ny_pixel, overlap_x, overlap_y );

% total number of vectors
mx = max(size(xi));
my = max(size(yi));

c_tmp = strcat( 'Total number of vectors =  ', ...
		int2str(mx), ' x ', int2str(my) );
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

    % set target window
    f1 = im1( ix1:ix2, iy1:iy2 );
    f2 = im2( ix1:ix2, iy1:iy2 );

    % calculate spatical cross-correlation, normal method
    % Cn = normxcorr2(f1,f2);
    try
      C = xcorr2_fast(f1,f2);
    catch
      C = xcorr2(f1,f2);
    end

%
% --- peak finding
%

    CC = C(nx_pixel-lx_pixel+1:nx_pixel+lx_pixel+1, ...
	   ny_pixel-ly_pixel+1:ny_pixel+ly_pixel+1);

    [ ip_x, ip_y, SNR, MMR, PPR ] = func_findpeak2( CC, 2 );

    ix_peak = - ( ip_x - lx_pixel );
    iy_peak = - ( ip_y - ly_pixel );

    if i_plot == 1
      %figure(2);clf;
      %surf( Cn );
      figure(1);clf;
      colormap(jet)
      surf( C );
      %contour( CC', 25 );
      hold on
        plot( ip_x, ip_y, 'bo', ...
	         'MarkerSize', 8, ...
	         'MarkerFaceColor', 'b', ...
	         'MarkerEdgeColor', 'k' );
      hold off
      disp( '>> push key' )
      pause
    end

%
% --- eliminate too large displacement
%

   if (iu_max == 0) & (iv_max == 0)
      u_max_dipl = p_search*nx_pixel;
      v_max_dipl = p_search*ny_pixel;
   else
      u_max_dipl = iu_max;
      v_max_dipl = iv_max;
   end

   if ( abs(ix_peak) > u_max_dipl ) | ( abs(iy_peak) > v_max_dipl )
     ix_peak = NaN;
     iy_peak = NaN;
   end

%
% --- eliminate small correlation by SNR and PPR filter
%
    if SNR < r_SNR | PPR < r_PPR 
      ix_peak = NaN;
      iy_peak = NaN;
    end

    is_x(ix,iy) = ix_peak;
    is_y(ix,iy) = iy_peak;

%
% --- end of main loop
%

   end
end 

%
% --- post process or second velocity field estimation with same window size
%

if i_mode == 1

  disp('> ' );
  disp('> Double checking velocity vector for same windiow size' );
  n_scale = 1;
  [xi,yi,iu,iv] = piv_crs( im1, im2, ... 
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

