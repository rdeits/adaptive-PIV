function[ uo ] = vector_interp_spline( ui )
%========================================================================
%
% version 1.0
%
%
% 	vector_interp_spline
%
%
% Description:
%
%	Interpolate NaN vector by cubic spline interpolation
%       + Specific
%	  - near boundary vector is interpolated by linear interpolation
%
% Variables:
%
%	Input;
%	ui		velocity vector
%			
%	Output;
%	uo		output velocity
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
%       1.01    2009/07/01 BSD License is applied
%	1.0	First version
%
%========================================================================

uo = ui;
mx = size(ui,1);
my = size(ui,2);

[ uo ] = vector_interp_linear( ui );

% main
for iy=3:my-2
  for ix=3:mx-2
    if isnan( ui(ix,iy) ) == 1
  uo(ix,iy) = 1/3*( ui(ix-1,iy) + ui(ix+1,iy) + ui(ix,iy-1) + ui(ix,iy+1) ) - 1/12*( ui(ix-2,iy) + ui(ix+2,iy) + ui(ix,iy-2) + ui(ix,iy+2) );
    end
  end
end
