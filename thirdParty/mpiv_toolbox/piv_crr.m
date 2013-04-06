function [xi, yi, iu, iv] = piv_crr( im1, im2, ...
			     nx_pixel, ny_pixel, ...
			     overlap_x, overlap_y, ...
			     iu_max, iv_max, ...
			     n_recur )
%========================================================================
%
% version 0.52
%
%
% 	piv_crr.m
%
%
% Description:
%
%	To calculate PIV displacement using correlation method 
%	with hierarchical (iterative) scheme.
%	This program is to be called by the main program 'mpiv.m'
%	  - correlation algorism
%	  - hierarchical/recursive algorism
%	  - search close to image edge
%	  - Gaussian subpixel fit
%
% Requires:
%	  - piv_cor.m
%	  - piv_crs.m
%	  - vector_check.m
%	  - vector_filter_linear.m
%	  - vector_filter_median.m
%	  - vector_filter_vecstd.m
%	  - vector_exterp_linear.m
%	  - vector_interp.m
%	  - vector_interp_kriging.m
%	  - vector_interp_kriging_local.m
%	  - vector_interp_linear.m
%	  - vector_interp_spline.m
%
% Requires toolboxes:
%
%   - This program requires DACE, Kriging Toolbox, developed by
%	S.N. Lophaven, H.B. Nielsen and J. Sondergaard
%	at Technical University of Denmark
%
% Variables:
%
%  Input:
%	im1 and 2	image files (double precision)
%	nx_pixel	subwindow size in x
%	ny_pixel	subwindow size in y
%	n_recur		down scale times		
%	overlap_x	overlap ratio of adjacent subwindows in x 
%			(typically 0.0 or 0.5)
%	overlap_y	overlap ratio of adjacent subwindows in y
%	iu_max		maximum displacement in x
%	iv_max		maximum displacement in y
%			-> iu_max and iv_max set limit for search area
%
%  Output:
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
%=======================================================================
%
% Update:
%       0.53    2009/07/01 BSD License applied
%	0.52	2003/06/16 i_mode has been inserted
%	0.50	2003/06/12 Main part has been separeted to piv_crs.m
%	0.30	2003/06/12 Interpolation has been modified
%	0.10	2003/06/11 Some bugs have been modified
%	0.01	2003/06/11 First version
%
%========================================================================

%
% <===== Input for professional use				<=====
%      can be replaced with other appropriate values

% i_plot = 1       : test plot 
%        = other   : no plot
i_plot = 9;

% set filter to eliminate stray vectors: 1-std, 2-median
i_filter = 2;

% Set threshold value (times of standard deviation) 
% Vectors will be eliminated if exceeded
vec_std = 1.5;

% set interpolation of missing vector	: 1-linear, 2-spline, 3-kriging
i_interp = 3;

% ratio of invalid vector to valid vector [0 - 1]
% 1 -> all vectors are NaN
i_numvec  = 1/2;

% i_mode = 1	; single check for final results
%	   2	; double check for final resutls
i_mode = 1;

% =====> End of input for professional use			======>

%
% --- check options (with or without iterative scheme)
%

disp('-> PIV using correlation algorism with hierarchical method')

%
% --- initialization
%

nx = size(im1,1);
ny = size(im1,2);

if i_mode == 1
  max_recur = n_recur;
else
  max_recur = n_recur + 1;
end

%
% --- initial peak search by mpiv_cor.m
%

[xi_1, yi_1, iu_t, iv_t] = piv_cor( im1, im2, ...
				    nx_pixel, ny_pixel, ...
				    overlap_x, overlap_y, ...
				    iu_max, iv_max, 0 );

% local fitering
[ iu_f, iv_f, i_cond ] = vector_check( iu_t, iv_t, vec_std, i_filter );

% check number of valid vector
[mx1,mx2] = func_countNaN( iu_f );
[my1,my2] = func_countNaN( iv_f );
if (1-mx2/mx1>i_numvec) | (1-my2/my1>i_numvec) 
  tmp   = [1-mx2/mx1 1-my2/my1];
  c_tmp = num2str( 100*i_numvec, ' %3.0f' );
  disp( 'Ratios of invalid vector are' ); disp( tmp );
  warning( strcat('Number of invalid vectors is more than ', c_tmp, '%') )
end

% interpolation of missing value
if max(max(isnan(iu_f))) ~= 0
  [ iu_1 ] = vector_interp( iu_f, i_interp );
else
  iu_1 = iu_f;
end

if max(max(isnan(iv_f))) ~= 0
  [ iv_1 ] = vector_interp( iv_f, i_interp );
else
  iv_1 = iv_f;
end

%
% --- second velocity field estimation with same window size
%

n_scale = 1;
[xi_2,yi_2,iu_2,iv_2] = piv_crs( im1, im2, ... 
				 xi_1, yi_1, iu_1, iv_1, ...
				 nx_pixel, ny_pixel, n_scale, ...
				 overlap_x, overlap_y, ...
				 iu_max, iv_max, ...
				 i_filter, vec_std, i_interp, ...
				 1, max_recur );

xi_1 = xi_2;
yi_1 = yi_2;
iu_1 = iu_2;
iv_1 = iv_2;

%
% --- start recursive PIV
%

for ir = 1:n_recur-1

  n_scale = 2^ir;

  [xi_2,yi_2,iu_2,iv_2] = piv_crs( im1, im2, ... 
				   xi_1, yi_1, iu_1, iv_1, ...
				   nx_pixel, ny_pixel, n_scale, ...
		 		   overlap_x, overlap_y, ...
 				   iu_max, iv_max, ...
				   i_filter, vec_std, i_interp, ...
				   ir+1, max_recur );

  %
  % --- test plot
  %

  if i_plot == 1
    quiver(iu_1,iv_1,'r-');
    hold on
    quiver(iu_2,iv_2,'b-');
    hold off
    pause
  end

  xi_1 = xi_2;
  yi_1 = yi_2;
  iu_1 = iu_2;
  iv_1 = iv_2;

end

%
% --- twice iteration for check
%

if i_mode == 2

  n_scale = 2^(n_recur-1);
  [xi_2,yi_2,iu_2,iv_2] = piv_crs( im1, im2, ... 
				   xi_1, yi_1, iu_1, iv_1, ...
				   nx_pixel, ny_pixel, n_scale, ...
				   overlap_x, overlap_y, ...
				   iu_max, iv_max, ...
				   i_filter, vec_std, i_interp, ...
				   n_recur+1, max_recur );

end

%
% --- end of this program
%

xi = xi_2;
yi = yi_2;
iu = iu_2;
iv = iv_2;
