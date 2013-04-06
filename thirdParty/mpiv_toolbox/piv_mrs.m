function [xi_2,yi_2, iu_2,iv_2] = piv_mrs( im1, im2, ... 
				     xi_1, yi_1, iu_1, iv_1, ...
				     nx_pixel, ny_pixel, n_scale, ...
				     overlap_x, overlap_y, ...
				     iu_max, iv_max, ...
				     i_filter, vec_std, i_interp, ...
				     ir, n_recur )
%========================================================================
%
% version 0.10
%
%
% 	piv_mrs.m
%
%
% Description:
%
%	This program is a part of
%	calculation of PIV displacement using MQD method 
%	with hierarchical (iterative) scheme.
%	This program is to be called by the main program 'piv_mqr.m'
%	  - simple MQD algorism
%	  - hierarchical/recursive algorism
%	  - search close to image edge
%	  - Gaussian subpixel fit
%
% Requires:
%	  - piv_mqd.m
%	  - piv_mqr.m
%	  - func_findpeak2.m
%	  - piv_windowsize.m
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
%			(should be larger than 20, typical 32 or 64)
%	ny_pixel	subwindow size in y
%			(should be larger than 20, typical 32 or 64)
%	overlap_x	overlap ratio of adjacent subwindows in x
%	overlap_y	overlap ratio of adjacent subwindows in y
%	iu_max		maximum displacement in x (unit: pixel)
%	iv_max		maximum displacement in y (unit: pixel)
%			-> iu_max and iv_max give search area
%	i_opt		= -1: no subpixel fit
%			=  1: with Gaussian subpixel fit
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
%======================================================================
%
% Update:
%       0.11    2009/07/01 BSD License applied
%	0.10	2003/07/02 MMR has been used to eliminate error vector
%	0.01	2003/07/01 First version
%
%========================================================================

%
% <===== Input for professional use				<=====
%      can be replaced with other appropriate values

% i_plot = 1        check plotting
%        = other    no plotting
i_plot = 9;

% SNR: signal to noise ratio to find peak
r_SNR = 3.0;

% r_peak: ratio of maximum and mean
r_MMR = 1.10;

% r_peak: ratio of 1st peak and 2nd peak
r_PPR = 1.05;

% set area of search
p_search = 1/3; 			% percentage of subwindow

% set minimum subwindow size for interrogation
n_window_min = 9;                       % pixel

% min and max values for MQD
d_min      = 10^(-5);
d_max      = Inf;

% =====> End of input for professional use			======>

%
% --- initialization
%

nx = size(im1,1);
ny = size(im1,2);

% window size
mx_pixel = nx_pixel/n_scale;
my_pixel = ny_pixel/n_scale;

[ xi_2,yi_2,mx_start,my_start,mx_overlap,my_overlap,dx_center, dy_center ] ...
    = func_pivwindowsize( 'mqd', ...
			  nx,ny, mx_pixel,my_pixel, overlap_x,overlap_y );

lx = max(size(xi_1));
ly = max(size(yi_1));
mx = max(size(xi_2));
my = max(size(yi_2));

disp(' ========================================')
c_tmp = strcat( '  Total number of vectors = ', ...
		int2str(mx),' x ',int2str(my) );
disp( c_tmp );
c_tmp = strcat( '  Interrogation window size = ', ...
		int2str(mx_pixel),' x ',int2str(my_pixel) );
disp( c_tmp );
disp(' ========================================')

%
% --- preprocess to interpolate velocity vector
%

[X1 Y1] = meshgrid(xi_1,yi_1);
[X2 Y2] = meshgrid(xi_2,yi_2);

[ ut, vt, i_cond ] = vector_check( iu_1, iv_1, vec_std, i_filter ); 

if i_interp == 3
  [ u ] = vector_interp_kriging_local( ut );
  [ v ] = vector_interp_kriging_local( vt ); 
else
  [ u ] = vector_interp_linear( ut );
  [ v ] = vector_interp_linear( vt ); 
  [ u ] = vector_exterp_linear( ut );
  [ v ] = vector_exterp_linear( vt ); 
end

% remove NaN vector
if i_interp ~= 3
  while max(max(isnan(u))) == 1
    [ u ] = vector_interp_linear( u );
    [ u ] = vector_exterp_linear( u );
    [ u ] = vector_interp_NaN( u );
  end  
  while max(max(isnan(v))) == 1
    [ v ] = vector_interp_linear( v );
    [ v ] = vector_exterp_linear( v );
    [ v ] = vector_interp_NaN( v );
  end
end

%
% --- predicting velocity vector using interp2 interpolation 
%

Ui = interp2( X1,Y1, u', X2, Y2, '*spline' );
Vi = interp2( X1,Y1, v', X2, Y2, '*spline' );
Ui = Ui';
Vi = Vi';

[ Ui, Vi, i_cond ] = vector_check( Ui, Vi, vec_std, i_filter ); 

if i_interp == 3
  [ UI ] = vector_interp_kriging_local( Ui );
  [ VI ] = vector_interp_kriging_local( Vi ); 
else
  [ UI ] = vector_exterp_linear( Ui );
  [ VI ] = vector_exterp_linear( Vi );
end

% test
if i_plot == 1
  figure(2);clf
  quiver(X1,Y1,u',v','r-');
  hold on
  quiver(X2,Y2,UI',VI','b-');
  quiver(X2,Y2,Ui',Vi','g-');
  hold off
  pause
end

%
% --- main routine
%

  for iy = 1:my

    c_proc = strcat( 'Recursive PIV step', ...
		   int2str(ir),'/',int2str(n_recur), ...
		   '.  Process accomplished : ', ...
		   num2str( 100*(iy-1)/(my-1),' %03.0f' ), '/100' );
    disp( c_proc )

    for ix = 1:mx

      % create target window from 1st image
      % location of target window
      ix1 = xi_2(ix) - dx_center;
      % ix1 = mx_start + (mx_pixel - mx_overlap)*(ix-1) + 1;
      ix2 = ix1 + mx_pixel - 1;
      iy1 = yi_2(iy) - dy_center;
      % iy1 = my_start + (my_pixel - my_overlap)*(iy-1) + 1;
      iy2 = iy1 + my_pixel - 1;

      % center of target window
      ix_center = xi_2(ix);
      iy_center = yi_2(iy);

      f1 = im1( ix1:ix2, iy1:iy2 );

      %
      % --- set search area
      %

      % search area must be larger than n_wind_min or 1+p_seach percentage
      mx_move = round( [ (1-p_search), (1+p_search) ]*UI(ix,iy) );
      my_move = round( [ (1-p_search), (1+p_search) ]*VI(ix,iy) );
      mx_d = abs( max(mx_move)-min(mx_move) );
      my_d = abs( max(my_move)-min(my_move) );
      lx = min( fix(mx_pixel/2)+1, n_window_min);
      ly = min( fix(my_pixel/2)+1, n_window_min);
      
      if mx_d > lx
        mx_movemin = min(mx_move);
        mx_movemax = max(mx_move);
      else
        mx_movemin = round(UI(ix,iy)) - ceil(lx/2);
        mx_movemax = round(UI(ix,iy)) + ceil(ly/2);
      end
      
      if my_d > ly
        my_movemin = min(my_move);
        my_movemax = max(my_move);
      else
        my_movemin = round(VI(ix,iy)) - fix(lx/2);
        my_movemax = round(VI(ix,iy)) + fix(ly/2);
      end

      % search area must be odd number
      if rem(mx_movemax-mx_movemin+1,2) == 0
        mx_movemax = mx_movemax + 1;
      end
      
      if rem(my_movemax-my_movemin+1,2) == 0
        my_movemax = my_movemax + 1;
      end

      % check the value of movemax
      if isnan(mx_movemax*mx_movemin*my_movemax*my_movemin) == 1
        mx_movemin = 0;
        mx_movemax = 0;
        my_movemin = 0;
        my_movemax = 0;
      end

      clear C;

      %
      % --- calculation uisng MQD
      %

      isy = 0;
      for jy = my_movemin:my_movemax
        isx = 0;
        isy = isy + 1;

        for jx = mx_movemin:mx_movemax
          isx = isx + 1;

          C(isx,isy) = d_min;

          %
          % --- create search subwindow in 2nd image
          %

          f2 = zeros(mx_pixel,my_pixel);

          kx1 = ix1 + jx;
          kx2 = kx1 + mx_pixel - 1;
          ky1 = iy1 + jy;
          ky2 = ky1 + my_pixel - 1;
          n   = mx_pixel*my_pixel;

          if ( kx1 >= 1 ) & ( kx2 <= nx ) & ( ky1 >= 1 ) & ( ky2 <= ny ) 
     
            f2 = im2( kx1:kx2, ky1:ky2 );   
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
     % --- peak finding /  C is odd number maxtrix
     %

     C = 1./C;

     % Peak finding with Gaussian subpixel fit
     [ ip_x, ip_y, SNR, MMR, PPR ] = func_findpeak2( C, -2 );

     ix_peak = mx_movemin + ip_x - 1;
     iy_peak = my_movemin + ip_y - 1;

     if i_plot == 1
       figure(1);clf;colormap(jet)
       %contour( C', 25 );
       surf(C');
       hold on
       C_max = max(max(C));
       plot3( ip_x, ip_y, C_max, 'bo', ...
	         'MarkerSize', 8, ...
	         'MarkerFaceColor', 'b', ...
	         'MarkerEdgeColor', 'k' );
       hold off
       disp( '-> push key' )
       pause
     end

     %
     % --- eliminate vectors with small MMR and PPR
     %

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
% --- post process
%

iu_2 = is_x;
iv_2 = is_y;
