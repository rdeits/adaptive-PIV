function [zs] = func_smooth(z)
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
% This program is to smooth 2d matrix.
% A 3*3 template (kernel) is used as the low-pass filter
% Input: 
%    z      input raw matrix
% Output
%   zs      smoothed matrix
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

kern = [1 2 1; 2 4 2; 1 2 1];     % exact for 50% overlap piv results

n_y = size(z,1);
n_x = size(z,2);
kern = kern / sum(sum(kern));

%-------------------starting smoothing
zs = zeros(n_y,n_x);
%inside boundary
for i = 2:n_x-1
   for j = 2:n_y-1
      area = z(j-1:j+1,i-1:i+1);
      zs(j,i) = sum(sum(area .* kern));
   end
end

%top and bottom boundaries   
j=1;
for i=2:n_x-1
   area(1,1:3) = z(j,i-1:i+1);
   area(2:3,1:3) = z(j:2,i-1:i+1);
   zs(j,i) = sum(sum(area .* kern));
end

j=n_y;
for i=2:n_x-1
   area(3,1:3) = z(j,i-1:i+1);
   area(1:2,1:3) = z(j-1:j,i-1:i+1);
   zs(j,i) = sum(sum(area .* kern));
end

%left and right boundaries
i=1;
for j=2:n_y-1
   area(1:3,1) = z(j-1:j+1,i);
   area(1:3,2:3) = z(j-1:j+1,i:2);
   zs(j,i) = sum(sum(area .* kern));
end

i=n_x;
for j=2:n_y-1
   area(1:3,3) = z(j-1:j+1,i);
   area(1:3,1:2) = z(j-1:j+1,i-1:i);
   zs(j,i) = sum(sum(area .* kern));
end

%four corners
j=1;
i=1;
   area(1,1) = z(1,1);
   area(2:3,2:3) = z(1:2,1:2);
   area(2:3,1) = z(1:2,1);
   area(1,2:3) = z(1,1:2);
   zs(j,i) = sum(sum(area .* kern));
j=1;
i=n_x;
   area(1,3) = z(1,i);
   area(2:3,1:2) = z(1:2,i-1:i);
   area(2:3,3) = z(1:2,i);
   area(1,1:2) = z(1,i-1:i);
   zs(j,i) = sum(sum(area .* kern));

j=n_y;
i=1;
   area(3,1) = z(j,1);
   area(1:2,2:3) = z(j-1:j,1:2);
   area(3,2:3) = z(j,1:2);
   area(1:2,1) = z(j-1:j,1);
   zs(j,i) = sum(sum(area .* kern));

j=n_y;
i=n_x;
   area(3,3) = z(j,i);
   area(1:2,1:2) = z(j-1:j,i-1:i);
   area(1:2,3) = z(j-1:j,i);
   area(3,1:2) = z(j,i-1:i);
   zs(j,i) = sum(sum(area .* kern));

