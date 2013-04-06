function[ uo ] = vector_interp( ui, i_interp )
%========================================================================
%
% version 1.0
%
%
% 	vector_interp
%
%
% Description:
%
%	Interpolate NaN vector
%       This progam requires:
%	  - vector_interp_linear.m
%	  - vector_interp_spline.m
%	  - vector_interp_kriging.m
%       + Specific
%	  - linear interpolation
%	  - cubic spline interpolation
%
% Requirement:
%
%	This program requires DACE, Kriging Toolbox, developed by
%   S.N. Lophaven, H.B. Nielsen and J. Sondergaard
%   at Technical University of Denmark
%
% Variables:
%
%	Input;
%	ui		velocity vector
%       i_interp = 1	linear interpolation
%       	   2	cubic spline interpolation
%       	   3	kriging interpolation
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
%	1.00	Kriging option has been inserted
%	0.10	First version
%
%========================================================================

uo = ui;

% --- linear interpolation

if i_interp == 1

[ uo ] = vector_interp_linear( ui );

% --- cubic spline interpolation

elseif i_interp == 2

[ uo ] = vector_interp_spline( ui );

% --- kriging interpolation

elseif i_interp == 3

[ uo ] = vector_interp_kriging_local( ui );

% --- end of this program

else

error( 'Error: invaild i_filter value' );

end
