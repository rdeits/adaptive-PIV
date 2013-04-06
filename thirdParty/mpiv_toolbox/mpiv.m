function [xi,yi,iu,iv,D]=mpiv( imr1, imr2, nx_window, ny_window, ...
			       overlap_x, overlap_y, iu_max, iv_max, dt, ...
			       piv_type, i_recur, i_plot)
%========================================================================
%
% version 0.961
%
%
% 	mpiv / Matlab PIV
%
%
% Description:
%
%	`mpiv' is the Particle Image Velocimetry (PIV) program for 
%	Matlab. This program require Matlab and Image Processing 
%	Toolbox is also require for coordinate transform, if it needs.
%
% Procedure:
%
%	- Preprocess
%	- PIV (select one of the follows)
%	  The velocity vectors are calculated by MQD algorithm.
%	  The velocity vectors are calculated by correlation algorithm.
%	  The velocity vectors are calculated by hierarchical algorithm
%	  The sub pixel peak seach is also avaiable.
%
%         (Postprocess is available, and recommended, using a separate 
%         program. See user manual for the details)
%
% Variables:
%
%	Input:
%
%	imr1 and 2	image files (double precision)
%	nx_window	subwindow size in x 
%			(should be larger than 20, typical 32 or 64)
%	ny_window	subwindow size in y
%	overlap_x	overlap ratio of adjacent subwindows in x 
%			(typically 0.0 or 0.5)
%	overlap_y	overlap ratio of adjacent subwindow in y
%	iu_max		maximum displacement in x (unit: pixel)
%	iv_max		maximum displacement in y (unit: pixel)
%			    -> iu_max and iv_max set limit for search area
% 	dt		time separation between im1 and im2 (in second)
%	piv_type	= 'mqd': MQD algorithm
%			= 'cor': Correlation algorithm
%			= other: do nothing
%	i_recur		= n: number of recursive and check
%			= 0: piv without double check
%			= 1: piv with double check
%			> 1: recursive
% 	i_plot		= 1 plot during piv process for checking
%			other -> no plotting
%
%	Output:
%
%	xi, yi		location of velocity vector
%	iu, iv		velocity vector
%       D		maximum value of MQD or correlation,
%				only used for 'mqc'
%
%   Input variables in 'piv_mqr.m':
% 	i_interp	= 1: linear interpolation
%			    = 2: cubic spline
%			    = 0: do nothing
% 	i_filter  	= 1: std filter 
% 	    		= 2: median filter 
%           	= 0: do nothing
%
% Note:
%       imr1, imr2, iu and iv are two dimensional matrices in
%        x and y direction, respectively [not y and x].
%
%========================================================================
%
% Example for running the mpiv program(s):
%
%   > im1 = imread('image1.bmp');
%   > im2 = imread('image2.bmp');
%
%   > [xi,yi,iu,iv]=mpiv(im1,im2, 32,32, 0.5,0.5, 20,20,1, 'cor', 2, 1);
%   or by
%   > [xi,yi,iu,iv] = mpiv(im1,im2, 64,64, 0.5,0.5, 20,20, 1, 'mqd', 2, 1);
%
%   To get rid of stray vectors and fill the 'holes':
%   > [iu_f,iv_f,iu_i, iv_i] = mpiv_filter(iu,iv, 2, 2.0, 3, 1);
%
%   To smooth out unrealistic changes in vectors:
%   (strongly recommended if you use 50% overlap ratio)
%   > [iu_s, iv_s] = mpiv_smooth(iu_i, iv_i, 1);
%
%   To calculate and plot vorticity:
%   > [vor] = mpiv_vor(iu_s, iv_s, 1);
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
%       0.97    2009/07/01 BSD License applied
%       0.961   2004/12/03 new sub function nanmean2.m has been inserted.
%       0.96    2003/10/08 mpiv_gui.m has been added.
%       0.95    2003/ 7/02 piv_mqd.m(1.00) and piv_mqr.m(0.53) 
%				piv_mrs.m has been inserted.
%				def.of MMR have been changed.
%       0.93    2003/ 6/26 piv_cor.m(0.73) and piv_crs.m(0.49)
%				vector_filter_median.m(0.60)
%				vector_filter_vecstd.m(0.60)
%				have been modified.
%			   func_histfilter.m has been inserted.
%       0.91    2003/ 6/23 piv_cor.m(0.70) and piv_crs.m(0.46) 
%				have been modified.
%       0.90    2003/ 6/20 piv_cor.m and piv_crs.m have been modified.
%       0.82    2003/ 6/16 piv_crs.m and kriging have been modified.
%       0.80    2003/ 6/12 Totally refined
%       0.70    2003/ 6/11 piv_crr.m has been inserted
%       0.65    2003/ 6/11 piv_cor.m has been modified, 0.60
%       0.60    2003/ 6/10 piv_*.m has been modified
%       0.54    2003/ 6/10 piv_cor.m has been improved by KAC
%			   piv_cor.m - version 0.50
%       0.53    2003/ 6/10 Comments in the code have been refined.
%	0.52	2003/04/07 peak search routines in piv_mqr and piv_mqd
%                          have been modified
%       0.51    2003/ 4/03 bug fixed in piv_mqr.m.
%       0.50    2003/ 4/01 piv_mqr.m has been inserted
%	0.32	2003/ 3/27 piv_mqd_c.m has been inserted
%	0.30	2002/12/04 piv_cor.m has been inserted
%	0.26	2002/10/21 piv_mqd.m has been modified
%	0.20	2002/09/20 change image input
%	0.15	2002/09/12 add vector interpolation routine
%	0.10	2002/09/12 add check error vector routine
%	0.01	2002/09/11 First version
%
%========================================================================

%
% --- initialization
%

t = cputime;
D = [];

%
% --- preprocessing
%

% transpose of the matrix im#(iy,ix) -> im#(ix,iy)
im1 = double( imr1' );
im2 = double( imr2' );

% check image sizes
nx  = size(im1,1);
ny  = size(im1,2);
nx2 = size(im2,1);
ny2 = size(im2,2);

if ( nx ~= nx2 ) | ( ny ~= ny2 )
  error('Error: image sizes are different!!!');
end

nx_window = round(nx_window);
ny_window = round(ny_window);

if overlap_x > 0.9 | overlap_y > 0.9
    error('Error: the overlap ratio is too large!!!')
end

disp('Preprocessing finished');

%
% --- select one of the piv methods for velocity determination
%

if ( piv_type == 'mqd' ) | ( piv_type == 'MQD' )


  if (abs(i_recur) == 0) | (abs(i_recur) == 1)

    [xi, yi, iu, iv] = piv_mqd( im1, im2, ...
  			nx_window, ny_window, ...
			overlap_x, overlap_y, ...
			iu_max, iv_max, ...
			i_recur );

  elseif abs(i_recur) <= 5

  [xi, yi, iu, iv] = piv_mqr( im1, im2, ...
		        nx_window, ny_window, ...
		        overlap_x, overlap_y, ...
		        iu_max, iv_max, ...
		        i_recur );

  elseif abs(i_recur) > 5

    error('Error: i_recur is too large !!!');

  end

elseif ( piv_type == 'mqc' ) | ( piv_type == 'MQC' )

  [xi, yi, iu, iv, D] = piv_mqd( im1, im2, ...
			nx_window, ny_window, ...
			overlap_x, overlap_y, ...
			iu_max, iv_max, ...
			i_recur );

elseif ( piv_type == 'cor' ) | ( piv_type == 'COR' )

  if (abs(i_recur) == 0) | (abs(i_recur) == 1)

    [xi, yi, iu, iv] = piv_cor( im1, im2, ...
  			nx_window, ny_window, ...
			overlap_x, overlap_y, ...
			iu_max, iv_max, ...
			i_recur );

  elseif abs(i_recur) <= 5

  [xi, yi, iu, iv] = piv_crr( im1, im2, ...
		        nx_window, ny_window, ...
		        overlap_x, overlap_y, ...
		        iu_max, iv_max, ...
		        i_recur );

  elseif abs(i_recur) > 5

    error('Error: i_recur is too large !!!');

  end

else

  error('Error: invalid piv_type !!!  piv_type is case sensitive');

end

%
% ---  dimension for velocity
%

iu = iu/dt;
iv = iv/dt;

%
% --- plot image and velocity
%

if i_plot == 1
  x = 1:nx;
  y = 1:ny;
  [XV YV] = meshgrid(xi, yi);
  % change image pixel value for plot
  image_max = max(max(im1));
  im = 75*im1/image_max;
  % transpose of the matrix for plotting: (x,y)->(y,x)
  image( x, y, im' );
  colormap(gray)
  hold on
  % transpose of the matrix: (x,y)->(y,x)
  quiver( XV, YV, iu', iv', 'g' );
  hold off
  xlabel('x (pixel)')
  ylabel('y (pixel)')
end

%
% --- output mean displacement, maximum displacement, elapstime,
%       and number of valid vectors
%

iu_tmp = reshape(iu, 1, size(iu,1)*size(iu,2));
tmp    = find(~isnan(iu_tmp));
iu_tmp = iu_tmp(tmp);
iv_tmp = reshape(iv, 1, size(iv,1)*size(iv,2));
tmp    = find(~isnan(iv_tmp));
iv_tmp = iv_tmp(tmp);
elapstime = cputime - t;

disp(' ')
disp(' ============================================================= ')
c_tmp = strcat( '> Mean displacement in x and y (pixel) = ', ...
                 num2str(nanmean2(abs(iu_tmp)),'%8.4f'), ' , ', ... 
                 num2str(nanmean2(abs(iv_tmp)),'%8.4f') );
disp( c_tmp )
c_tmp = strcat( '> Maximum displacement in x and y (pixel) = ', ...
                 num2str(max(max(abs(iu_tmp))),'%8.4f'), ' , ', ... 
                 num2str(max(max(abs(iv_tmp))),'%8.4f') );
disp( c_tmp )
c_tmp = strcat( '> Number of valid vectors versus total vectors = ', ...
                 num2str(length(tmp),'%8.0f'), ' , ', ... 
                 num2str(size(iv,1)*size(iv,2),'%8.0f') );
disp( c_tmp )
c_tmp = strcat( '> Elapsed time (second) =', num2str(elapstime,'%15.7e') );
disp( c_tmp )
disp(' ============================================================= ')

