function[ iu_f, iv_f, i_cond ] = vector_check( iu, iv, vec_std, i_filter )
%========================================================================
%
% version 1.0
%
%
% 	vector_check.m
%
%
% Description:
%
%	check velocity vector
%	This program is called by mpiv.m
%       + Specific
%	  - 
%
% Variables:
%
%	Input;
%	iu, iv		velocity vector
%	vec_std		threshold value to eliminate error vecor
%			usutally 2.0-3.0
%       i_filter = 1	standard deviation filter
%       	 = 2	median filter
%       	 = 3	global filter
%
%	Output;
%	ius, ivs	corrected velocity vector
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

mx = size(iu,1);
my = size(iu,2);

%vec_std = 3.0;

%
% --- check velocity vector by standard deviation
%

if i_filter == 1

c_tmp = strcat('standard mean value filter is used : r=', ...
	       num2str( vec_std,'%5.2f') );
disp(c_tmp)
[ iu_f, i_cond ] = vector_filter_vecstd( iu, vec_std );
[ iv_f, i_cond ] = vector_filter_vecstd( iv, vec_std );

%
% --- check velocity vector by median filter
%

elseif i_filter == 2

c_tmp = strcat('median filter is used : r=', ...
	       num2str( vec_std,'%5.2f') );
disp(c_tmp)
[ iu_f, i_cond ] = vector_filter_median( iu, vec_std );
[ iv_f, i_cond ] = vector_filter_median( iv, vec_std );

%
% --- check velocity vector by global filter
%

elseif i_filter == 3

c_tmp = strcat('global filter is used : r=', ...
	       num2str( vec_std,'%5.2f') );
disp(c_tmp)
[ iu_f, iv_f ] = vector_filter_global( iu, iv, vec_std );

%
% --- end of this program
%

else

error( 'Error: invaild i_filter value' );

end

% Avoid one vel. comp is NaN and the other is not
iu_f = iu_f - iv_f*0;
iv_f = iv_f - iu_f*0;
