function [iu_s,iv_s] = mpiv_smooth( iu, iv, i_plot)
%========================================================================
%
% version 1.0
%
%
% 	mpiv_smooth.m
%
%
% Description:
%
%	vector smoothing by weighting method
%
% Specific:
%
% Variables:
%
%	Input:
%	  iu, iv	Input vectors 
%			(calculated by mpiv.m with empty vectors filled)
% 	  i_plot    	= 1 plot the before and after smoothed figures
%
%   Output:
%	  iu_s, iv_s	smoothed velocity vectors
%
% Example:
%
%	[iu_s,iv_s] = mpiv_smooth(iu,iv, 1);
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
%	1.00	2003/06/11 First version by KAC
%
%========================================================================

iu_s = func_smooth(iu);
iv_s = func_smooth(iv);

if i_plot == 1
%    figure
%    quiver( iu', iv');
%    xlabel('x axis')
%    ylabel('y axis')
%    set(gca,'YDir','reverse')
%    title('Before Smoothing')
  
   figure
   quiver( iu_s', iv_s');
   xlabel('x axis')
   ylabel('y axis')
   set(gca,'YDir','reverse')
   title('After Smoothing')
end
