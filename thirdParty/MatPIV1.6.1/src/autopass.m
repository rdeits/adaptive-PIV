function [x,y,u,v,SnR,Pkh]=autopass(im1,winsize,Dt,overlap,wshift,maske)

% function [x,y,u,v,snr,pkh]=autopass(im1,winsize,Dt,overlap,windowshift)
% 
% Provides autocorrelation PIV with a single pass through the image
% specified in IM1 with the interrogation window size WINSIZE. The 
% interrogation windows are allowed to overlap by the amount specified
% in OVERLAP (meas. in percent). DT is the time between exposures.
% WSHIFT specifies the artificial window shift that is usually applied
% to resolve directional ambiguity that arises from using the
% autocorrelation function. WSHIFT=[Xshift Yshift] should be a vector 
% containing the appropriate shifts in X- and Y-directions.
% All results are measured in pixels or pixels/cm.
% See also:
%            MATPIV, INTPEAK, DEFINEWOCO, PIXEL2WORLD,
%            MULTIPASS, DESAMPLEPASS, VALIDATE, HISTOOP
%            DIFFQUANT, INTQUANT


% Users may wish to watch the correlation plane during the
% calculations.
% This will greatly increase the computation time, but is very nice
% for visualization purposes. Uncomment the following line to create
% a separate window for this and also uncomment the appropriate lines 
% at the bottom of  the for loop:
%h1=figure(1); set(h1,'Position',[0 315 500 400]); 
%h2=figure(2); set(h2,'Position',[0 115 150 100]); set(h2,'Interruptible','off');

% Image read
A=double(imread(im1));
B=A;
[sy,sx]=size(A);
% Various declarations
N=winsize;
M=N;
ci1=1;
cj1=1;
x=zeros(ceil((size(A,1)-winsize)/((1-overlap)*winsize)),ceil((size(A,2)-winsize)/((1-overlap)*winsize)));
y=x; u=x; v=x;

if nargin==6, 
  if ~isempty(maske)
    IN=zeros(size(maske(1).msk));
    for i=1:length(maske)
      IN=IN+double(maske(i).msk);
    end
  else 
    IN=zeros(size(A)); 
  end 
end


% Create bias correction matrix
BiCor=xcorrf2(ones(winsize),ones(winsize))/(winsize*winsize);

% Create warning if window shift is not specified.
if wshift(1)==0 & wshift(2)==0
  disp('WARNING! window shift is not specified. All velocities are absolute values')
end
tic
% MAIN LOOP
for jj=1:(1-overlap)*winsize:size(A,1)-winsize
  for ii=1:(1-overlap)*winsize:size(A,2)-winsize
    if IN(jj+N/2,ii+M/2)~=1
      C=A(jj:jj+winsize-1,ii:ii+winsize-1);
      D=B(jj:jj+winsize-1,ii:ii+winsize-1);
      % Calculate the standard deviation of each of the subwindows
      stad1=std2(C); stad2=std2(D);
      % Subtract the mean of each window to avoid correlation of
      % this mean.
      C=C-mean2(C);
      D=D-mean2(D);
      % Calculate the correlation using the xcorrf2 (found at the 
      % Mathworks web site). Divide by N (winsize) and the stad's 
      % to normalize the peakheights.
      R=xcorrf2(C,D)/(winsize*winsize*stad1*stad2);
      % Correct for displacement bias
      %R=R./BiCor;    
      % Locate the highest point. 
      % Hopefully it lies in the middle of the image :-)
      [y1,x1]=find(R==max(max(R(0.5*winsize+2:1.5*winsize-3,0.5*winsize+2:1.5*winsize-3))));
      if size(x1,1)>1 | size(y1,1)>1 
	x1=x1(1);
	y1=y1(1);
      end
      
      % Now we should subtract the image shift, if available, so that there is
      % only one second highest peak in the correlation plane   
      R2=R;
      R2(y1-5:y1+5,x1-5:x1+5)=NaN;
      if wshift(1)==0 & wshift(2)==0
	[y2,x2]=find(R2==max(max(R2(3:end-4,3:end-4))));
	if length(x2)==1
	  try
	    D1=B(jj+y2:jj+winsize-1+y2,ii+x2:ii+winsize-1+x2);
	  catch 
	    if jj+y2<1
	      y2=1-jj;
	    elseif jj+y2>sy-winsize+1
	      y2=sy-winsize+1-jj;
	    end       
	    if ii+x2<1
	      x2=1-ii;    
	    elseif ii+x2>sx-winsize+1
	      x2=sx-winsize+1-ii;
	    end	  
	    D1=B(jj+y2:jj+winsize-1+y2,ii+x2:ii+winsize-1+x2);
	  end
	  try
	    D2=B(jj-y2:jj+winsize-1-y2,ii-x2:ii+winsize-1-x2);
	  catch 
	    if jj-y2<1
	      y2=1-jj;
	    elseif jj-y2>sy-winsize+1
	      y2=sy-winsize+1-jj;
	    end       
	    if ii-x2<1
	      x2=1-ii;    
	    elseif ii-x2>sx-winsize+1
	      x2=sx-winsize+1-ii;
	    end
	    D2=B(jj-y2:jj+winsize-1-y2,ii-x2:ii+winsize-1-x2);
	  end
	  
	  stad21=std2(D1); stad22=std2(D2); D1=D1-mean2(D1); D2=D2-mean2(D2);
	  
	  Rx1=xcorrf2(C,D1)/(winsize*winsize*stad1*stad21); 
	  Rx2=xcorrf2(C,D2)/(winsize*winsize*stad1*stad22); 	
	  
	  if max(Rx1(:))>max(Rx2(:))
	    [y2,x2]=find(Rx1==max(max(Rx1(3:end-4,3:end-4))));
	  else
	    [y2,x2]=find(Rx2==max(max(Rx2(3:end-4,3:end-4))));
	  end
	else 
	  disp('unable to determine shift')
	  return
	end
      else
	[y2,x2]=find(R2==max(max(R2(3-wshift(2):end-4-wshift(2),3- wshift(1):end-4-wshift(1)))));
      end
      %if wshift(1)==0 | wshift(2)==0
      %  y2=y2(1);
      %  x2=x2(1);
      %eend    
      % Interpolate to find the peak position at subpixel resolution,
      % using three point curve fit function INTPEAK.
      % X0,Y0 now denotes the displacements.
      [x0,y0]=intpeak(x2,y2,R(y2,x2),R(y2,x2-1),R(y2,x2+1),R(y2-1,x2),R(y2+1,x2),1,winsize);
    
      % Find the SnR and peakheight.
      R3=R2;
      R3(y1-4:y1+4,x1-4:x1+4)=NaN; R3(y2-3:y2+3,x2-3:x2+3)=NaN;
      %[y3,x3]=find(R3==max(max(R3(0.5*N+2-wshift(2):1.5*N-3-wshift(2),0.5*M+2-wshift(1):1.5*M-3-wshift(1)))));
      [y3,x3]=find(R3==max(max(R3)));
      % Store the data
      x(cj1,ci1)=(winsize/2)+ii-1;
      y(cj1,ci1)=(winsize/2)+jj-1;
      u(cj1,ci1)=-x0/Dt;
      v(cj1,ci1)=-y0/Dt;
      SnR(cj1,ci1)=R2(y2(1),x2(1))/R3(y3(1),x3(1));
      Pkh(cj1,ci1)=R2(y2(1),x2(1));
      % Update counters
      ci1=ci1+1;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plotting
      % Uncomment the following to display the correlation peak 
      % during calculation and the following to plot vectors along the way 
      %figure(2)
      %imshow(R(1.5*winsize:0.5*winsize,1.5*winsize:0.5*winsize),[],'notruesize')
    else
      x(cj1,ci1)=(winsize/2)+ii-1;
      y(cj1,ci1)=(winsize/2)+jj-1;
      u(cj1,ci1)=NaN;
      v(cj1,ci1)=NaN;
      SnR(cj1,ci1)=NaN;
      Pkh(cj1,ci1)=NaN;  ci1=ci1+1;
    end  
    
  end
  % Uncomment here as well:
  %figure(1), quiver(x,y,u,v);
  % Display calculation time
  disp([num2str((cj1-1)*(ci1)+ci1) ' vectors in ' num2str(toc) ' seconds'])
  ci1=1;
  cj1=cj1+1;
end
