function[ uo, vo ] = vector_filter_global( ui, vi, r_MM )
%========================================================================
%
% version 0.01
%
%
% 	vector_filter_global.m
%
%
% Description:
%
%	Remove stray vectors using global filter.
%	  - error vector exceeds > r_MM*mean is replaced by NaN
%
% Variables:
%
%	Input:
%	ui, vi		velocity vector
%   	r_MM		threshold value (typically 2 to 3)
%			
%	Output:
%	uo, vo		output velocity vector
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
%       0.02    2009/07/01 BSD License is applied
%	0.01	           First version
%
%========================================================================

uo = ui;
vo = vi;
u  = uo(~isnan(uo));
v  = vo(~isnan(vo));
mx = size(uo,1);
my = size(uo,2);

u_mean = mean2(u);
v_mean = mean2(v);
u_std  =  std2(u);
v_std  =  std2(v);
U_std  = sqrt( u_std^2 + v_std^2 );

for iy=1:my
  for ix=1:mx
    r = sqrt( (ui(ix,iy)-u_mean)^2 + (vi(ix,iy)-v_mean)^2 )/U_std;
    if r >= r_MM
      uo(ix,iy) = NaN;
      vo(ix,iy) = NaN;
    end
  end
end
