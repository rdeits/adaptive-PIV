function [R]=rawmqd(im1,im2,met)

%
%
%
 
%disp('* MQD - method (raw calculation - this WILL be slow)')

if nargin==2, met='none'; end

[N,M]=size(im1);

im1sum=sum(im1(:).^2);

if strcmp(met,'pad')
  tmp1=zeros(3*N,3*M);
  tmp2=tmp1;
  tmp1(N+1:2*N,M+1:2*M)=im1;
  tmp2(N+1:2*N,M+1:2*M)=im2;
  s1=2*N; s2=2*M;
else
  tmp1=zeros(2*N,2*M);
  tmp2=tmp1;
  tmp1(N/2 +1:3*N/2,M/2 +1:3*M/2)=im1;
  tmp2(N/2 +1:3*N/2,M/2 +1:3*M/2)=im2;
  s1=N; s2=M;
end
  
for m=1:s2
  for n=1:s1
    tmp=im1.*tmp2(n:N+n-1,m:M+m-1);
    
    R(n,m)=(im1sum - 2*sum(tmp(:)) + sum(sum( tmp2(n:N+n-1,m:M+m-1).^2)));   
  end
end
R(1,:)=[]; R(:,1)=[];
