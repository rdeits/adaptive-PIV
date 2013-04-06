function [xi_2,yi_2, iu_2,iv_2] = piv_crs( im1, im2, ... 
				     xi_1, yi_1, iu_1, iv_1, ...
				     nx_pixel, ny_pixel, n_scale, ...
				     overlap_x, overlap_y, ...
				     iu_max, iv_max, ...
				     i_filter, vec_std, i_interp, ...
				     ir, n_recur )
%========================================================================
%
% version 0.495
%
%
% 	piv_crs.m
%
%
% Description:
%
%	This program is a part of
%	calculation of PIV displacement using correlation method 
%	with hierarchical (iterative) scheme.
%	This program is to be called by the main program 'piv_crr.m'
%	  - correlation algorism
%	  - hierarchical/recursive algorism
%	  - search close to image edge
%	  - Gaussian subpixel fit
%
% Requires:
%	  - piv_cor.m
%	  - piv_crr.m
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
%========================================================================
%
% Update:
%       0.50    2009/07/01 BSD License applied
%	0.495	2003/07/01 func_findpeak2.m and def. of SNR have been changed.
%	0.49	2003/06/26 Filtering after interpolation has been removed.
%	0.48	2003/06/23 PPR has been added.
%	0.46	2003/06/23 xcorr2_fast has been inserted
%	0.45	2003/06/20 normxcorr2 has been replaced by xcorr2
%	0.40	2003/06/16 Some bugs have been modified
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

% SNR: signal to noise ratio to find peak
r_SNR  = 3.00;

% r_peak: ratio of 1st peak and 2nd peak
r_PPR = 1.10;

% set area of search
p_search = 1/3; 			% percentage of subwindow

% minimum pixel of search window
n_pixel_min = 3;

% =====> End of input for professional use			======>

%
% --- initalization
%

nx = size(im1,1);
ny = size(im1,2);

% window size
mx_pixel = nx_pixel/n_scale;
my_pixel = ny_pixel/n_scale;

% maximum space lag in correlation function
lx_pixel = ceil(p_search*mx_pixel);
ly_pixel = ceil(p_search*my_pixel);
if lx_pixel < n_pixel_min
   lx_pixel = n_pixel_min;
end
if ly_pixel < n_pixel_min
   ly_pixel = n_pixel_min;
end

[ xi_2,yi_2,mx_start,my_start,mx_overlap,my_overlap,dx_center,dy_center ] ...
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
  whos X1 Y1 u v
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

    c_proc = strcat( 'Recursive PIV step : ', ...
		   int2str(ir),'/',int2str(n_recur), ...
		   '.  Process accomplished : ', ...
		   num2str( 100*(iy-1)/(my-1),' %03.0f' ), '/100' );
    disp( c_proc )

    for ix = 1:mx

      i_void = 0;

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
      % ---- creating reference window from second image
      %

      % center of reference window
      ix_center = round( UI(ix,iy) );
      iy_center = round( VI(ix,iy) );

      % create reference window from 2st image
      % location of reference window

      jx1 = ix1 + ix_center;
      jx2 = ix2 + ix_center;
      jy1 = iy1 + iy_center;
      jy2 = iy2 + iy_center;
      
      % shift image for some case
      if ( jx1<1 ) | ( jx2>nx ) | ( jy1<1 ) | ( jy2>ny )
        i_void = 1;
      elseif (isnan(jx1)==1) | (isnan(jx2)==1) | (isnan(jy1)==1) | (isnan(jy2)==1)
        i_void = 1;
      else
        f2 = im2( jx1:jx2, jy1:jy2 );
      end

      %
      % --- peak finding /  C is odd number maxtrix
      %

      if i_void == 0;

        try
          C = xcorr2_fast(f1,f2);
        catch
          C = xcorr2(f1,f2);
        end

        % Peak finding with Gaussian subpixel fit
        CC = C(mx_pixel-lx_pixel+1:mx_pixel+lx_pixel+1, ...
 	       my_pixel-ly_pixel+1:my_pixel+ly_pixel+1);

        [ ip_x, ip_y, SNR, MMR, PPR ] = func_findpeak2( CC, 2 );

        ix_peak = - (ip_x - lx_pixel); % - xcorr2, + normxcorr2
	iy_peak = - (ip_y - ly_pixel); % - xcorr2, + normxcorr2

        if i_plot == 1
	  clf
          colormap(jet)
          surf(C)
          %contour( C', 25 );
          hold on
          plot( ip_x, ip_y, 'ro', ...
  	         'MarkerSize', 8, ...
  	         'MarkerFaceColor', 'r', ...
	         'MarkerEdgeColor', 'k' );
          hold off
          disp( '-> push key' )
          pause
        end

        %
        % --- eliminate vectors with small SN ratio in correlation
        %

        if SNR < r_SNR | PPR < r_PPR
          ix_peak = NaN;
          iy_peak = NaN;
        end

        is_x(ix,iy) = ix_peak + ix_center;
        is_y(ix,iy) = iy_peak + iy_center;

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

        if ( abs(is_x(ix,iy)) > u_max_dipl ) | ( abs(is_y(ix,iy)) > v_max_dipl )
          is_x(ix,iy) = NaN;
          is_y(ix,iy) = NaN;
        end


      else

        if i_void == 1
%          is_x(ix,iy) = NaN;
%          is_y(ix,iy) = NaN;
          is_x(ix,iy) = UI(ix,iy);
          is_y(ix,iy) = VI(ix,iy);
        end

      end

    %
    % --- end of main loop
    %

    end
  end 

%
% --- post process
%

iu_2 = real(is_x);
iv_2 = real(is_y);
