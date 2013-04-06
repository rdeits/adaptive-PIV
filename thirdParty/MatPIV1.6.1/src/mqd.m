function [x,y,u,v,snr,Pkh]=mqd(im1,im2,win,Dt,overlap,ms)
  
% MQD - minimum quadratic difference method for velocity
% measurements. 
% [x,y,u,v]=mqd(im1,im2,win,Dt,overlap,ms)
%
% This function implements the method by Gui & Merzkirch (2000). 
%
% c. 2. August 2000, Kristian Sveen, jks@math.uio,no 
% for use with MatPIV 1.6

%time stamp: 26. August 2002

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
[sta,ind]=dbstack; % to suppress output if called from MATPTV

% Precondition added 23. Oct 2002
%[A,B]=precondition(A,B);

% Weight function added 2004
W=weight('cosn',win,20);
% Various declarations
M=win; N=M; ci1=1; cj1=1;
x=zeros(ceil((size(A,1)-win)/((1-overlap)*win)), ...
    ceil((size(A,2)-win)/((1-overlap)*win)));
y=x; u=x; v=x; 

if nargin==6, if ~isempty(ms)
        IN=zeros(size(ms(1).msk));
        for i=1:length(ms), IN=IN+double(ms(i).msk); end
else IN=zeros(size(A)); 
end, end
if size(sta,1)<=1  
  disp('* MQD - method')
else
  if isempty(findstr(sta(end).name,'matptv')) 
    disp('* MQD - method')
  end
end

SA=std(A(:)); 

tic
for jj=1:(1-overlap)*win:size(A,1)-win+1
    for ii=1:(1-overlap)*win:size(A,2)-win+1
        if IN(jj+N/2,ii+M/2)~=1
            C=A(jj:jj+win-1,ii:ii+win-1);
            D=B(jj:jj+win-1,ii:ii+win-1);
            % Calculate the standard deviation of each of the subwindows
            stad1=std(C(:)); stad2=std(D(:));
            if stad1<0.2*SA
                stad1=NaN; 
            end
            if stad2<0.2*SA
                stad2=NaN; 
            end
            % Subtract the mean of each window to avoid correlation of
            % this mean.
            C=C-mean(C(:)); C=C.*W;
            D=D-mean(D(:)); D=D.*W;
            % perform MQD using the function SUBMQD
            if isnan(stad1)~=1 & isnan(stad2)~=1
                R=submqd(C,D); %/(stad2*stad1);
                % Locate the lowest point
                [y1,x1]=find(R==min(min(R(2:end-3,2:end-3))));
                if size(x1,1)>1 | size(y1,1)>1 
                    x1=x1(1);
                    y1=y1(1);
                end
                % Interpolate to find the peak position at subpixel resolution,
                % using three point curve fit function INTPEAK.
                % X0,Y0 now denotes the displacements.
                if x1==1, x1=2; end, if x1==size(R,2), x1=size(R,2)-1; end
                if y1==1, y1=2;	end, if y1==size(R,1), y1=size(R,1)-1; end
                [x0,y0]=intpeak(x1,y1,R(y1,x1),R(y1,x1-1),R(y1,x1+1),...
                    R(y1-1,x1),R(y1+1,x1),2,win/2);
                R2=max(R(:))-R; limx=min([5 (win-x1) (x1-1)]);limy=min([5 (win-y1) (y1-1)]);
                R2(y1-limy:y1+limy,x1-limx:x1+limx)=NaN;
                [p2_y2,p2_x2]=find(R2==max(max(R2(2:end-3,2:end-3))));
                if size(p2_y2,1)>1 | size(p2_x2,1)>1 
                    p2_y2=p2_y2(1);
                    p2_x2=p2_x2(1);
                end
                % Store the data
                x(cj1,ci1)=(win/2)+ii-1;
                y(cj1,ci1)=(win/2)+jj-1;
                u(cj1,ci1)=x0/Dt;
                v(cj1,ci1)=y0/Dt;
                snr(cj1,ci1)=(max(R(:))-R(y1,x1))/R2(p2_y2,p2_x2);
                Pkh(cj1,ci1)=R(y1,x1);	
            else
                u(cj1,ci1)=NaN; v(cj1,ci1)=NaN; snr(cj1,ci1)=NaN; Pkh(cj1,ci1)=NaN; 
                x(cj1,ci1)=(ii+(win/2)-1);
                y(cj1,ci1)=(jj+(win/2)-1);
            end
            
            % Update counters
            ci1=ci1+1;
        else
            x(cj1,ci1)=(win/2)+ii-1;
            y(cj1,ci1)=(win/2)+jj-1;
            u(cj1,ci1)=NaN;
            v(cj1,ci1)=NaN;
            snr(cj1,ci1)=NaN;
            Pkh(cj1,ci1)=NaN; ci1=ci1+1;
        end  
        
    end
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
