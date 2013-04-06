function [x,y,u,v,SnR,Pkh,u2,v2]=normpass(im1,im2,winsize,Dt,overlap,maske)
%SINGLEPASS - Particle Image Velocimetry with fixed interrogation regions.
%
%function [x,y,u,v,snr,pkh]=singlepass2(im1,im2,winsize,Dt,overlap,mask)
%Provides PIV with a single pass through the images specified in IM1
%and IM2 with the interrogation window size WINSIZE. The interrogation
%windows are allowed to overlap by the amount specified in OVERLAP
%(meas. in percent). DT is the time between the images.  All results are
%measured in pixels or pixels/cm.  See also: MATPIV, INTPEAK,
%DEFINEWOCO, PIXEL2WORLD, MULTIPASS, SNRFILT, GLOBFILT
%LOCALFILT


% Copyright 1998-2000, Kristian Sveen, jks@math.uio.no 
% for use with MatPIV 1.5
% Distributed under the terms of the Gnu General Public License
% Time stamp: 22:02, Feb 20 2001

% Image read
if ischar(im1)
    [A p1]=imread(im1);
    [B p2]=imread(im2);
    if any([isrgb(A), isrgb(B)])
        A=rgb2gray(A); B=rgb2gray(B);
    end
    
    if ~isempty(p1), A=ind2gray(A,p1); end
    if ~isempty(p2), B=ind2gray(B,p2); end
else
    A=im1; B=im2;
end   

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
disp(['* Single pass - calculating the full correlation coefficient', ...
      ' (normalized correlations)'])
SA=std(A(:));
tic
% MAIN LOOP
for jj=1:(1-overlap)*winsize:size(A,1)-winsize+1
    for ii=1:(1-overlap)*winsize:size(A,2)-winsize+1
        if IN(jj+N/2,ii+M/2)~=1
            C=A(jj:jj+winsize-1,ii:ii+winsize-1);
            D=B(jj:jj+winsize-1,ii:ii+winsize-1);
	    indic=0;
            % Calculate the standard deviation of each of the subwindows
            stad1=std(C(:));stad2=std(D(:));
            if stad1<0.2*SA, stad1=NaN; end %filter based on the
                                             %available pattern
            if stad2<0.2*SA, stad2=NaN; end
            % Subtract the mean of each window to avoid correlation of
            % the mean background intensities.
            C=C-mean(C(:));
            D=D-mean(D(:)); 
            % uncomment below to use weighting
            C=C.*W; D=D.*W;
            
            if ~isnan(stad1) & ~isnan(stad2)
                R=normxcorr2(C,D);
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
                [x02,y02]=intpeak(p2_x2,p2_y2,R2(p2_y2,p2_x2),R2(p2_y2,p2_x2-1),...
				  R2(p2_y2,p2_x2+1),R2(p2_y2-1,p2_x2),R2(p2_y2+1,p2_x2),2,winsize);
		% Store the data
                x(cj1,ci1)=(winsize/2)+ii-1;
                y(cj1,ci1)=(winsize/2)+jj-1;
                u(cj1,ci1)=x0/Dt;
                v(cj1,ci1)=y0/Dt;
                SnR(cj1,ci1)=R(y1,x1)/R2(p2_y2,p2_x2);
                Pkh(cj1,ci1)=R(y1,x1);
		u2(cj1,ci1)=stad1; %x02/Dt;
		v2(cj1,ci1)=stad2; %y02/Dt;
            else
                u(cj1,ci1)=NaN; v(cj1,ci1)=NaN; 
		SnR(cj1,ci1)=NaN; Pkh(cj1,ci1)=NaN; 
                x(cj1,ci1)=(ii+(winsize/2)-1);
                y(cj1,ci1)=(jj+(winsize/2)-1);
		u2(cj1,ci1)=stad1; %x02/Dt;
		v2(cj1,ci1)=stad2;
            end

        else
            x(cj1,ci1)=(winsize/2)+ii-1;
            y(cj1,ci1)=(winsize/2)+jj-1;
            u(cj1,ci1)=NaN;
            v(cj1,ci1)=NaN;
            SnR(cj1,ci1)=NaN;
            Pkh(cj1,ci1)=NaN;  
	    u2(cj1,ci1)=NaN;
	    v2(cj1,ci1)=NaN;
	    %ci1=ci1+1;
        end  
	% Update counters
	ci1=ci1+1;
    end
    % Display calculation time
    fprintf('\r No. of vectors: %d', (cj1-1)*(ci1)+ci1-1 -sum(isnan(u(:))))
    fprintf(' , Seconds taken: %f', toc); %etime(clock,t0));
    ci1=1;
    cj1=cj1+1;
end

fprintf('.\n');

