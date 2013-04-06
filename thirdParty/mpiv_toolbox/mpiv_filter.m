function [iu_ft,iv_ft,iu_ip,iv_ip]=mpiv_filter( iu,iv, ...
						i_filter, vec_std,...
						i_interp, i_plot)
%========================================================================
%
% version 0.3
%
%
% 	mpiv_filter.m
%
%
% Description:
%
%	vector filtering, interpolation after mpiv
%
% Specific:
%
%	- Preprocess
%
% Variables:
%
%	Input:
%	  iu, iv	Input vectors (calculated by mpiv.m)
% 	  i_filter  	= 1: std filter 
% 	    		= 2: median filter 
%               	= 0: do nothing
%	  vec_std	threshold value to determine/eliminate stray vecors
% 			(usutally set as 1.5 to 3.0)
% 	  i_interp	= 1: linear interpolation
%			= 2: cubic spline
%			= 3: kriging  interpolation
%			= 0: do nothing
% 	  i_plot    	= 1 plot during piv process with pause for checking
%       		other -> do nothing
%
%   Output:
%	  iu_ft, iv_ft	filtered velocity vectors
%	  iu_ip, iv_ip	interpolated velocity vectors (for missing vectors)
%
% Example:
%
%	[iu_ft,iv_ft,iu_i,iv_i] = mpiv_filter(iu,iv, 1, 2.5, 1, 1);
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
%       1.01    2009/07/01 BSD License applied
%	1.00	2003/06/11 Refined by KAC
%	0.20	2002/09/20 change image input
%	0.15	2002/09/12 add vector interpolation routine
%	0.10	2002/09/12 add check error vector routine
%	0.01	2002/09/11 First version
%
%========================================================================

%
% --- post processing: local fitering
%

if i_filter ~= 0

  [ iu_ft, iv_ft, i_cond ] = vector_check( iu, iv, vec_std, i_filter );

end

%
% --- post processing: interpolation of missing value
%

if i_interp ~= 0 

  [ iu_ip ] = vector_interp( iu_ft, i_interp );
  [ iv_ip ] = vector_interp( iv_ft, i_interp );

else
    
  iu_ip = iu_ft;
  iv_ip = iv_ft;

end

%
% --- plot
%

if i_plot == 1
  figure
  if i_interp ~= 0
    quiver( iu_ip', iv_ip', 'r' );
    hold on
    quiver( iu_ft', iv_ft', 'b' );
    hold off
  else
    quiver( iu_ft', iv_ft', 'b' );
  end
  xlabel('x axis')
  ylabel('y axis')
  set(gca,'YDir','reverse')
end
