function[ u_mean, u_std, u_med] = func_histfilter( u )
% To calculate mean and standard deviation by filtering out the 
% large deviations
% Input variable "u" must be in row or column vector format
% Output:
%        mean, standard deviation and median values
%
%======================================================================
% Terms:
%
%       Distributed under the terms of the terms of the BSD License
%
%========================================================================

% --------------- Start Input -------------------

% Set range (times standard deviation)
std_limit = 2.0;

% ---------------End of Input -------------------

tmp = find(~isnan(u));
f = u(tmp);
f_mean = mean(f);
f_std = std(f);

% remove the values outside the "std_limitd" times "std" and recalculate mean and standard dev.

for i = 1:length(f)
    if abs(f(i)-f_mean) > (std_limit*f_std)
        f(i) = NaN;
    end
end

tmp2 = find(~isnan(f));
f2 = f(tmp2);
u_mean = mean(f2);
u_std = std(f2);
u_med = median(f2);
