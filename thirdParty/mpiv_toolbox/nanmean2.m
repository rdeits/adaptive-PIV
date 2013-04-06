function y = nanmean2(x)
%
% nanmean 2 average ignoring NaNs for 2D variable
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

if isempty(x) % Check for empty input.
    y = NaN;
    return
end

% Replace NaNs with zeros.
nans = isnan(x);
i = find(nans);
x(i) = zeros(size(i));

% count terms in sum over first non-singleton dimension
dim = find(size(x)>1);
if isempty(dim)
   dim = 1;
else
   dim = dim(1);
end
count = sum(sum(~nans,dim));

% Protect against a column of all NaNs
i = find(count==0);
count(i) = 1;
y = sum(sum(x,dim))./count;
y(i) = NaN;
