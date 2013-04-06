function [m,n] = func_countNaN( fi );

%======================================================================
%
% count number of NaN in 2D variable fi
% m : number of array in fi
% n : number of valid value (non-NaN0 in fi
%
%======================================================================
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

f1 = fi;
f2 = fi(~isnan(fi));

m = size(f1,1)*size(f1,2);
n = size(f2,1)*size(f2,2);
