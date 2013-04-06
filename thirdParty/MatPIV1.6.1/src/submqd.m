function [R]=submqd(im1,im2,met)

% SUBMQD - subfunction for use with MQD
% function [R]=submqd(im1,im2,method)
%
% METHOD can be any of 'orig', 'conv', 'fft', 'vec', 'corr','corrpad'
%
% corr - uses FFT based correlations to calculate R=(im1-im2)^2
% here we apply that R=im1.^2 -2 im1 im2 + im2.^2, which means that 
% the mqd equals an auto-correlation of im1 + autocorrelation of im2 
% minus 2 times the cross-correlation between im1 and im2.
%
% corrpad - same as above, but uses zero-padding in the FFTs.
%
% 'conv' and 'fft' methods written by Dave M. Goodman
% 'vec' method written by Stefan Stoll
%
% c. 2000-2003, Kristian Sveen, jks@math.uio,no 
% for use with MatPIV 1.6
% Time stamp: June 8 2003 20:07

if nargin==2
    met='new'; % Use the correlation-version if not defined
end 

[ii,jj]=size(im1); [ii2,jj2]=size(im2); 

% Original loop:
switch met
  
 case {'new','corr'}       
  F1=fft2(im1); F2=fft2(im2); F1j=conj(F1); F2j=conj(F2);
  F1sum=sum(sum(im1.^2));
  R= F1sum - 2*ifft2(F1j.*F2) + ifft2(F2j.*F2);
  R=real(fftshift(R)); 
  R(1,:)=[]; R(:,1)=[];
 case {'newpad','corrpad'}  
  n=nextpow2(ii);
  mf = 2^nextpow2(ii+ii2);
  nf = 2^nextpow2(jj+jj2);
  F1=fft2(im1,mf,nf); F2=fft2(im2,mf,nf); F1j=conj(F1); F2j=conj(F2);
  F1sum=sum(sum(im1.^2));
  R=F1sum - 2*ifft2(F1j.*F2) + ifft2(F2j.*F2);
  R(end,:)=[]; R(:,end)=[];
  R=real(fftshift(R)); 
  R=R(round(ii/2)+2:3*round(ii/2),round(jj/2)+2:3*round(jj/2));
 case {'newpad2','corrpad2'}  
  n=nextpow2(ii);
  mf = 2^nextpow2(ii+ii2);
  nf = 2^nextpow2(jj+jj2);
  F1=fft2(im1,mf,nf); F2=fft2(im2,mf,nf); F1j=conj(F1); F2j=conj(F2);
  R= ifft2(F1j.*F1) - 2*ifft2(F1j.*F2) + ifft2(F2j.*F2);
  R(end,:)=[]; R(:,end)=[];
  R=real(fftshift(R)); 
  R=R(round(ii/2)+2:3*round(ii/2),round(jj/2)+2:3*round(jj/2));
 case {'corrcoeff'}       
  F1sum=sum(sum(im1.^2));
  R=F1sum-2*normxcorr2(im1,im2)+normxcorr2(im2,im2);
  R=R(round(ii/2)+1:3*round(ii/2)-1,round(jj/2)+1:3*round(jj/2)-1);
  
 case {'raw'}
  R=rawmqd(im1,im2);
 case {'rawpad'} 
  %this will be SLOW
  R=rawmqd(im1,im2,'pad');
  R=R(round(ii/2)+1:3*round(ii/2)-1,round(jj/2)+1:3*round(jj/2)-1);
 case {'orig','original'}
  R=zeros(size(im1)); 
  % pad with zeros : is this a good idea? maybe mean(im) or NaN
  % instead?
  im22=zeros(ii*2,jj*2); im22(ii/2 : 3*ii/2-1, jj/2:3*jj/2-1)=im2;
  % Pad with mean
  % m1=mean(im1(:)); m2=mean(im2(:));
  % im22=m2*ones(ii*2,jj*2); im22(ii/2 : 3*ii/2-1, jj/2:3*jj/2-1)=im2;
  
  for m=1:ii+1
    for n=1:jj+1    
      tmp=(im1-im22(m:m+ii-1,n:n+jj-1)).^2;
      R(m,n)= nansum(tmp(:));
    end
  end
    
 case 'conv'
  R=zeros(size(im1)); 
  im22=zeros(ii*2,jj*2); im22(ii/2 : 3*ii/2-1, jj/2:3*jj/2-1)=im2;
  
  % vectorized contribution by 
  % Dave Goodmanson, dgoodmanson@worldnet.att.net
  R = conv2(im22.^2,ones(size(im1)),'valid') ...
      -2*conv2(im22,flipud(fliplr(im1)),'valid') ...
      +sum(sum(im1.^2));
  
 case 'fft'
  R=zeros(size(im1)); 
  im22=zeros(ii*2,jj*2); im22(ii/2 : 3*ii/2-1, jj/2:3*jj/2-1)=im2;
  
  %Further developed vectorized solution, now using FFTs 
  % to do the Convolutions.
  %[ia,ja]=size(im1);
  [ib,jb]=size(im22);
  A1 = zeros(size(im22));
  A1(1:ii,1:jj) = im1;
  onz = A1~=0;
  R =  ifft2(conj(fft2(onz)).*fft2(im22.^2)) ...
       -2*ifft2(conj(fft2(A1)).*fft2(im22));
  R = R(1:ib-ii+1,1:jb-jj+1) + sum(sum(im1.^2));
  R(end-1:end,:)=[]; R(:,end-1:end)=[];
  
  % Version by Stefan Stoll, <stoll@phys.chem.ethz.ch>
  % Faster than the original, slower than CONV approach
 case 'vec'
  R=zeros(size(im1)); 
  im22=zeros(ii*2,jj*2); im22(ii/2 : 3*ii/2-1, jj/2:3*jj/2-1)=im2;
  
  %[ia,ja] = size(im1);
  [ib,jb] = size(im22);
  R = zeros(ib-ii+1,jb-jj+1);
  for m = 1:ib-ii+1
    for n = 1:jb-jj+1
      tmp = reshape(im1-im22(m:m+ii-1,n:n+jj-1),ii*jj,1);
      R(m,n) = tmp.'*tmp;
    end
  end
  
end 

% return real variable
R=real(R);
