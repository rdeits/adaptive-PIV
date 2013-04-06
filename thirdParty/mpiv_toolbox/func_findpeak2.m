function [ ip_x, ip_y, SNR, MMR, PPR ] = func_findpeak2( f, i_opt );
%========================================================================
%
% version 0.55
%
%
% 	func_findpeak2.m
%
%
% Description:
%
%	To find the location of the peak of a 2D array
%	  - with optional Gaussian subpixel fit
%
% Variables:
%
%	Input;
%	f		2d array (double precision)
%	i_opt		= 1: normal algorism
%			= 2: subpixel fit
%
%	Output;
%	ip_x, ip_y	location of peak
%	SNR		signal to noise ratio 
%			(ratio of peak value to mean value of f)
%	MMR		max to mean ratio 
%	PPR		1st peak to 2nd peak ratio 
%
%
%=======================================================================
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
%	0.56	2009/07/01 BSD License applied
%	0.55	2006/12/08 Fixed minor bug for iopt=1
%	0.50	2006/09/12 NM Depress waring errors of Log(0) 
%	0.40	2003/07/01 Definition of MMR has been inserted.
%	0.30	2003/07/01 Definition of SNR has been modified
%	0.20	2003/06/11 Definition of SNR has been modified
%	0.10	2002/12/04 first version
%
%========================================================================

% i_plot = 1     -> plot during piv process with pause for check
%        = other -> void
i_plot = 9;

%
% --- initialization
%

nx = size(f,1);
ny = size(f,2);
n  = nx*ny;

n0 = size(f(~isnan(f)),1);

%
% --- remove abnormal conditions
%

if ( n0 == 0 ) | ( n==0 ) | ( max(max(f))==0 )
  ip_x = NaN;
  ip_y = NaN;
  SNR  = NaN;
  MMR  = NaN;
  PPR  = NaN;
  return
end

%
% --- peak search 1: normal
%

ip_x = -1;
ip_y = -1;

f_max = f(1,1);
for iy=1:ny
  g = f(:,iy);
  [g_max ig] = max( g );
  if g_max >= f_max 
    f_max = g_max; 
    ip_x  = ig;
  end
end

f_max = f(1,1);
for ix=1:nx
  g = f(ix,:);
  [g_max ig] = max( g );
  if g_max >= f_max 
    f_max = g_max; 
    ip_y  = ig;
  end
end

% for second peak search
h     = f(ip_x,ip_y);
ip_x0 = ip_x;
ip_y0 = ip_y;

%
% --- peak search 2: subpixel seach using Gaussian
%

if abs(i_opt) == 2

  if ( ip_x == -1 ) | ( ip_y == -1 )
     ip_x = NaN;
     ip_y = NaN;
     return
  end

  % calculate x-subpixel peak
  g = f(:,ip_y);
  [h ih] = max( g );
  g = g/h;
  if ih == 1
    ix_subpeak = 1;
  elseif ih == nx
    ix_subpeak = nx;
  else
    % v0.50
    if g(ih+1)~=0 & g(ih)~=0 & g(ih-1)~=0
      ix_subpeak = ih - 0.5*( log(g(ih+1)) - log(g(ih-1)) ) / ...
                  ( log(g(ih+1)) -2*log(g(ih)) + log(g(ih-1)) );
    else
      ix_subpeak = NaN;
    end
  end

  % calculate y-subpixel peak
  g = f(ip_x,:);
  [h ih] = max( g );
  g = g/h;
  if ih == 1
    iy_subpeak = 1;
  elseif ih == ny
    iy_subpeak = ny;
  else
    % v0.50
    if g(ih+1)~=0 & g(ih)~=0 & g(ih-1)~=0
      iy_subpeak = ih - 0.5*( log(g(ih+1)) - log(g(ih-1)) ) / ...
                    ( log(g(ih+1)) -2*log(g(ih)) + log(g(ih-1)) );
    else
      iy_subpeak = NaN;
    end
  end

  ip_x0 = ip_x;
  ip_y0 = ip_y;
  ip_x  = ix_subpeak;
  ip_y  = iy_subpeak;

end

%
% --- find second peak
%

% maximum value of 1st peak
C1=h;
g =f;
% Search for 2nd peak (outside dia_peak from the 1st peak)
dia_peak = round(sqrt(3*nx)/2.5);
%dia_peak = 5;

lx1 = ip_x0 - dia_peak;
lx2 = ip_x0 + dia_peak;
ly1 = ip_y0 - dia_peak;
ly2 = ip_y0 + dia_peak;
if lx1 < 1
  lx1 = 1;
elseif lx2 > nx
  lx2 = nx;
end
if ly1 < 1
  ly1 = 1;
elseif ly2 > ny
  ly2 = ny;
end
g(lx1:lx2,ly1:ly2) = 0;
C2 = max(max(g));

%ip2_x = -1;
%ip2_y = -1;
%g_max = g(1,1);
%for iy=1:ny
%  [h_max ih] = max( g(:,iy) );
%  if h_max >= g_max 
%    g_max = h_max; 
%    ip2_x  = ih;
%  end
%end
%g_max = g(1,1);
%for ix=1:nx
%  [h_max ih] = max( g(ix,:) );
%  if h_max >= g_max 
%    g_max = h_max; 
%    ip2_y  = ih;
%  end
%end

%
% --- post process
%

% Signal-to-Noise Ratio
if i_opt > 1
  g = f;
else
  g = f(find(f));
end
if max(size(g)) > 2
  f_max   = max(max(g));
  f_std   =    std2(g);
  f_mean  =   mean2(g);
  f_amean = mean2(abs(g));
else
  f_max   = NaN;
  f_std   = NaN;
  f_mean  = NaN;
  f_amean = NaN;
end

MMR = f_max/f_amean;
SNR = (f_max-f_mean)/f_std;

% Peak-to-Peak Ratio
if C2~=0
  PPR = C1/C2;
else
  PPR = Inf;
end

%
% --- check plot
%

if i_plot == 1

  contour( f', 25 );
%  surf( double(f)', 25 );
  hold on
    plot( ip_x, ip_y, 'bo', ...
	         'MarkerSize', 8, ...
	         'MarkerFaceColor', 'b', ...
	         'MarkerEdgeColor', 'k' );
    if abs(i_opt) == 2
    plot( ip_x0, ip_y0, 'ro', ...
	         'MarkerSize', 8, ...
	         'MarkerFaceColor', 'r', ...
	         'MarkerEdgeColor', 'k' );
%    plot( ip2_x, ip2_y, 'go', ...
%	         'MarkerSize', 8, ...
%	         'MarkerFaceColor', 'g', ...
%	         'MarkerEdgeColor', 'k' );
    end
  hold off
  pause
end
