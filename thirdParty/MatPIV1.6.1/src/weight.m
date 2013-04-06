function [w]=weight(func,siz,dev)

% WEIGHT - create weighting-function for use with MatPIV.
%
% [w]=weight(func,siz,n)
% 
% func is one of 'gaussian', 'hanning', 'blackman', 'triang', 
%  'hann', 'bartlett', 'cosn'
% 
% 'gaussian' additionally requires 'n' (standard deviation) to 
% be specified.
% if 'cosn' is specified, 'n' should be the appropriate factor in
% w(t) = 1-(cos(t)^n)

% Husk paperet fra Gottingen
  
if nargin~=2 & nargin~=3
  disp('Wrong input to WEIGHT-function')
  return
end

if ~isnumeric(siz)
  disp('Size should be a scalar or a length 2 vector')
end

if ~ischar(func)
  disp('Weight-function should be a string')
end

if exist('dev')
  if strcmp(dev,'gaussian') | strcmp(dev,'cosn')
    disp('Please give appropriate ''n''')
    return
  end
end
if length(siz)==1
  n=siz; m=siz/2; N=siz; M=siz/2;
elseif length(siz)==2
  n=siz(1); m=siz(1)/2; N=siz(2); M=siz(2)/2;
else
  disp('Wrong size argument input to WEIGHT');return
end
switch lower(func)
 case 'gaussian'
  hsize=[N,n];
  hsize=(hsize-1)/2 
  [x,y] = meshgrid(-hsize(2):hsize(2),-hsize(1):hsize(1));
  x=x./(max(x(:))); y=y./(max(y(:))); %normalize so that -1<= x,y <=1
  w= exp( -( (x.*x)./(dev^2) + (y.*y)./(dev^2) ));
  
  %f1=exp((-( ((1:n)-m)/n).^2)/dev); f2=exp((-( ((1:N)-M)/N).^2)/dev);
  %w=f1'*f2;
 case 'hanning'
  w = .5*(1 - cos(2*pi*(0:m-1)'/(n-1))); w2 = .5*(1 - cos(2*pi*(0:M-1)'/(N-1)));
  w = [w; w(end:-1:1)];  w2 = [w2; w2(end:-1:1)]; 
  w=w*w2';
 case 'hann'
  w = 0.5 * (1 - cos(2*pi*(0:m-1)'/(n-1)));  w2 = 0.5 * (1 - cos(2*pi*(0:M-1)'/(N-1))); 
  w = [w; w(end:-1:1)];  w2 = [w2; w2(end:-1:1)]; 
  w=w*w2';
 case 'hamming'
  w = (54 - 46*cos(2*pi*(0:m-1)'/(n-1)))/100; w2 = (54 - 46*cos(2*pi*(0:M-1)'/(N-1)))/100;
  w = [w; w(end:-1:1)]; w2 = [w2; w2(end:-1:1)]; 
  w=w*w2';
 case 'blackman'
  w = (42 - 50*cos(2*pi*(0:m-1)/(n-1)) + 8*cos(4*pi*(0:m-1)/(n-1)))'/100;
  w2 = (42 - 50*cos(2*pi*(0:M-1)/(N-1)) + 8*cos(4*pi*(0:M-1)/(N-1)))'/100;
  w = [w; w(end:-1:1)]; w2 = [w2; w2(end:-1:1)]; w=w*w2';
 case 'cosn'
  w = (1-cos(pi*(0:n-1)/(n-1)).^dev);    w2 = (1-cos(pi*(0:N-1)/(N-1)).^dev);
  w = w'*w2;
 otherwise 
  disp('Unknown function type. Check your input.')
end