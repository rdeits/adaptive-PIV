function [x,y,u,v,SnR,Pkh,u2]=singlepass(im1,im2,winsize,Dt,overlap,maske)
%SINGLEPASS - Particle Image Velocimetry with fixed interrogation regions.
%
%function [x,y,u,v,snr,pkh]=singlepass2(im1,im2,winsize,Dt,overlap,mask)
%Provides PIV with a single pass through the images specified in IM1
%and IM2 with the interrogation window size WINSIZE. The interrogation
%windows are allowed to overlap by the amount specified in OVERLAP
%(meas. in percent). DT is the time between the images.  All results are
%measured in pixels or pixels/cm.  See also: MATPIV, INTPEAK,
%DEFINEWOCO, PIXEL2WORLD, MULTIPASS, DESAMPLEPASS, SNRFILT, GLOBFILT
%LOCALFILT


% Copyright 1998-2000, Kristian Sveen, jks@math.uio.no 
% for use with MatPIV 1.6.1
% Distributed under the terms of the Gnu General Public License
% Time stamp: 10:47, Jun 03 2004

% Image read
if ischar(im1)
    [A p1]=imread(im1);    [B p2]=imread(im2);
    if any([isrgb(A), isrgb(B)])
        A=rgb2gray(A); B=rgb2gray(B);
    end   
    if ~isempty(p1), A=ind2gray(A,p1); end
    if ~isempty(p2), B=ind2gray(B,p2); end
else
    A=im1; B=im2;
end   
[sta,ind]=dbstack; % to suppress output if called from MATPTV
A=double(A); B=double(B);
%A=double(imread(im1)); B=double(imread(im2));
% Various declarations
M=winsize; N=M; ci1=1; cj1=1;
x=zeros(ceil((size(A,1)-winsize)/((1-overlap)*winsize)), ...
    ceil((size(A,2)-winsize)/((1-overlap)*winsize)));
y=x; u=x; v=x; 
dumx=ones(size(A,1),1) * ([1:size(A,2)]);
dumy=([1:size(A,1)].') * ones(1,size(A,2));
if nargin==6, if ~isempty(maske)
        IN=zeros(size(maske(1).msk));
        for i=1:length(maske)
            IN=IN+double(maske(i).msk);
        end
    else IN=zeros(size(A)); end, end
% Create bias correction matrix
BiCor=xcorrf2(ones(winsize),ones(winsize))/(winsize*winsize);
% change 4. october 2001, weight matrix added.
W=weight('cosn',winsize,20); 
%t0=clock;
if size(sta,1)<=1  
  disp('* Single pass')
else
  if isempty(findstr(sta(end).name,'matptv')) 
    disp('* Single pass')
  end
end
SA=std(A(:));

tic
% MAIN LOOP
for jj=1:(1-overlap)*winsize:size(A,1)-winsize+1
    for ii=1:(1-overlap)*winsize:size(A,2)-winsize+1
        if IN(jj+N/2,ii+M/2)~=1
            C=A(jj:jj+winsize-1,ii:ii+winsize-1);
            D=B(jj:jj+winsize-1,ii:ii+winsize-1);
            % Calculate the standard deviation of each of the subwindows
            stad1=std(C(:));stad2=std(D(:));
            if stad1<0.2*SA, stad1=NaN; end
            if stad2<0.2*SA, stad2=NaN; end
            % Subtract the mean of each window to avoid correlation of
            % the mean background intensities.
            C=C-mean(C(:));
            D=D-mean(D(:)); 
            % uncomment below to use weighting
            C=C.*W; D=D.*W;

            % Calculate the correlation using the xcorrf2 (found at the 
            % Mathworks web site). Divide by N (winsize) and the stad's 
            % to normalize the peakheights.
            if isnan(stad1)~=1 & isnan(stad2)~=1
                R=xcorrf2(C,D)./(winsize*winsize*stad1*stad2);
                % Correct for displacement bias
                R=R./BiCor;    
                % Locate the highest point   
                [y1,x1]=find(R==max(max(R(0.5*winsize+2:1.5*winsize-3,...
                    0.5*winsize+2:1.5*winsize-3))));
                if size(x1,1)>1 | size(y1,1)>1 
		  x1=round(sum(x1.*([1:length(x1)]'))./sum(x1));
		  y1=round(sum(y1.*([1:length(y1)]'))./sum(y1));
		end
                % Interpolate to find the peak position at subpixel resolution,
                % using three point curve fit function INTPEAK.
                % X0,Y0 now denotes the displacements.
                [x0,y0]=intpeak(x1,y1,R(y1,x1),R(y1,x1-1),R(y1,x1+1),...
				R(y1-1,x1),R(y1+1,x1),2,winsize);
                R2=R;
                R2(y1-3:y1+3,x1-3:x1+3)=NaN;
                [p2_y2,p2_x2]=find(R2==max(max(R2( 0.5*N+2:1.5*N-3,0.5*M+2:1.5*M-3))));
                if length(p2_x2)>1
                    p2_x2=p2_x2(round(length(p2_x2)/2)); 
                    p2_y2=p2_y2(round(length(p2_y2)/2)); 
                end
                % Store the data
                x(cj1,ci1)=(winsize/2)+ii-1;
                y(cj1,ci1)=(winsize/2)+jj-1;
                u(cj1,ci1)=-x0/Dt;
                v(cj1,ci1)=-y0/Dt;
                SnR(cj1,ci1)=R(y1,x1)/R2(p2_y2,p2_x2);
                Pkh(cj1,ci1)=R(y1,x1);
		u2(cj1,ci1)=sum(R(:));
            else
                u(cj1,ci1)=NaN; v(cj1,ci1)=NaN; SnR(cj1,ci1)=NaN; Pkh(cj1,ci1)=NaN; u2(cj1,ci1)=nan;
                x(cj1,ci1)=(ii+(winsize/2)-1);
                y(cj1,ci1)=(jj+(winsize/2)-1);
            end
            % Update counters
            ci1=ci1+1;
        else
            x(cj1,ci1)=(winsize/2)+ii-1;
            y(cj1,ci1)=(winsize/2)+jj-1;
            u(cj1,ci1)=NaN;
            v(cj1,ci1)=NaN;
            SnR(cj1,ci1)=NaN;
            Pkh(cj1,ci1)=NaN;  u2(cj1,ci1)=nan;
	    ci1=ci1+1;
        end  

    end
    % Display calculation time
    if size(sta,1)<=1   
      fprintf('\r No. of vectors: %d', (cj1-1)*(ci1)+ci1-1 -sum(isnan(u(:))))
      fprintf(' , Seconds taken: %f', toc); %etime(clock,t0));
    else
      if isempty(findstr(sta(end).name,'matptv'))   
	fprintf('\r No. of vectors: %d', (cj1-1)*(ci1)+ci1-1 -sum(isnan(u(:))))
	fprintf(' , Seconds taken: %f', toc); %etime(clock,t0));
      end
    end  
    
    ci1=1;
    cj1=cj1+1;
end

if size(sta,1)<=1  
  fprintf('.\n');
else
  if isempty(findstr(sta(end).name,'matptv')) 
      fprintf('.\n');
  end
end

% now we inline the function XCORRF2 to shave off some time.

function c = xcorrf2(a,b)
%  c = xcorrf2(a,b)
%   Two-dimensional cross-correlation using Fourier transforms.
%       XCORRF2(A,B) computes the crosscorrelation of matrices A and B.
%       XCORRF2(A) is the autocorrelation function.
%       This routine is functionally equivalent to xcorr2 but usually faster.
%       See also XCORR2.

%       Author(s): R. Johnson
%       $Revision: 1.0 $  $Date: 1995/11/27 $

[ma,na] = size(a);
% if nargin == 1
%     %       for autocorrelation
%     b = a;
% end
[mb,nb] = size(b);
%       make reverse conjugate of one array
b = conj(b(mb:-1:1,nb:-1:1));

%       use power of 2 transform lengths
mf = 2^nextpow2(ma+mb);
nf = 2^nextpow2(na+nb);
at = fft2(b,mf,nf);
bt = fft2(a,mf,nf);
%       multiply transforms then inverse transform
c = ifft2(at.*bt);
%       make real output for real input
if ~any(any(imag(a))) & ~any(any(imag(b)))
    c = real(c);
end
%  trim to standard size
c(ma+mb:mf,:) = [];
c(:,na+nb:nf) = [];
