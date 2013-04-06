function [xp,yp,up,vp,SnR,Pkh]=finalpass(A,B,N,ol,idx,idy,Dt,maske)
% function [x,y,u,v,SnR,PeakHeight]=finalpass(A,B,N,ol,idx,idy,Dt,mask)
% 
% Provides the final pass to get the displacements with 
% subpixel resolution.
%
%

% 1999 - 2001, J. Kristian Sveen (jks@math.uio.no)
% For use with MatPIV 1.6, Copyright
% Distributed under the terms of the GNU - GPL license
% timestamp: 14:03, 7 Nov 2001
if length(N)==1
    M=N;
else
    M=N(1); N=N(2);
end
ci=1; cj=1;
[sy,sx]=size(A);

% Allocate space for matrixes
x=zeros(ceil((size(A,1)-N)/((1-ol)*N))+1, ...
    ceil((size(A,2)-M)/((1-ol)*M))+1);
y=x; u=x; v=x; 

if nargin==8, if ~isempty(maske)
        IN=zeros(size(maske(1).msk));
        for i=1:length(maske)
            IN=IN+double(maske(i).msk);
        end
    else IN=zeros(size(A)); end, end

fprintf([' - Using ',num2str(M),'*',num2str(N),...
        ' interrogation windows! \n'])
%%%%%%%%%%%%%%% MAIN LOOP %%%%%%%%%%%%%%%%%%%%%%%%%
tic
for jj=1:((1-ol)*N):sy-N+1
    ci=1;
    for ii=1:((1-ol)*M):sx-M+1     
        if IN(jj+N/2,ii+M/2)~=1
            if isnan(idx(cj,ci))
                idx(cj,ci)=0;
            end
            if isnan(idy(cj,ci))
                idy(cj,ci)=0;
            end
            if jj+idy(cj,ci)<1
                idy(cj,ci)=1-jj;
            elseif jj+idy(cj,ci)>sy-N+1
                idy(cj,ci)=sy-N+1-jj;
            end       
            if ii+idx(cj,ci)<1
                idx(cj,ci)=1-ii;    
            elseif ii+idx(cj,ci)>sx-M+1
                idx(cj,ci)=sx-M+1-ii;
            end
            D2=B(jj+idy(cj,ci):jj+N-1+idy(cj,ci),ii+idx(cj,ci):ii+M-1+idx(cj,ci));
            E=A(jj:jj+N-1,ii:ii+M-1);
            stad1=std(E(:));
            stad2=std(D2(:)); 
            if stad1==0, stad1=1; end
            if stad2==0, stad2=1; end
            E=E-mean(E(:));
            F=D2-mean(D2(:));
            %E(E<0)=0; F(F<0)=0;            

            %%%%%%%%%%%%%%%%%%%%%% Calculate the normalized correlation: 
            R=xcorrf2(E,F)./(N*M*stad1*stad2);
            %%%%%%%%%%%%%%%%%%%%%% Find the position of the maximal value of R
            %%%%%%%%%%%%%%%%%%%%%% _IF_ the standard deviation is NOT NaN.
            if all(~isnan(R(:))) & ~all(R(:)==0)  %~isnan(stad1) & ~isnan(stad2)
              if size(R,1)==(N-1)
                [max_y1,max_x1]=find(R==max(R(:)));
                
              else
                [max_y1,max_x1]=find(R==max(max(R(0.5*N+2:1.5*N-3,...
                                                  0.5*M+2:1.5*M-3))));
              end
              if length(max_x1)>1
                max_x1=round(sum(max_x1.^2)./sum(max_x1));
                max_y1=round(sum(max_y1.^2)./sum(max_y1));
              end
              if max_x1==1, max_x1=2; end
              if max_y1==1, max_y1=2; end
              
                % 3-point peak fit using centroid, gaussian (default)
                % or parabolic fit
                [x0 y0]=intpeak(max_x1,max_y1,R(max_y1,max_x1),...
                                R(max_y1,max_x1-1),R(max_y1,max_x1+1),...
                                R(max_y1-1,max_x1),R(max_y1+1,max_x1),2,[M,N]);
              
                % Find the signal to Noise ratio
                R2=R; 
              try
                R2(max_y1-3:max_y1+3,max_x1-3:max_x1+3)=NaN;
              catch 
                R2(max_y1-1:max_y1+1,max_x1-1:max_x1+1)=NaN;
              end
              if size(R,1)==(N-1)
                [p2_y2,p2_x2]=find(R2==max(R2(:)));
                
              else
                [p2_y2,p2_x2]=find(R2==max(max(R2(0.5*N:1.5*N-1,0.5*M:1.5*M-1))));
              end
              if length(p2_x2)>1
                p2_x2=p2_x2(round(length(p2_x2)/2)); 
                p2_y2=p2_y2(round(length(p2_y2)/2)); 
              elseif isempty(p2_x2)
                
              end
              % signal to noise:
              snr=R(max_y1,max_x1)/R2(p2_y2,p2_x2);
              % signal to mean:
              %snr=R(max_y1,max_x1)/mean(R(:));                
              % signal to median:
              %snr=R(max_y1,max_x1)/median(median(R(0.5*N+2:1.5*N-3,...
              %    0.5*M+2:1.5*M-3)));
              
              %%%%%%%%%%%%%%%%%%%%%% Store the displacements, SnR and Peak Height.
              up(cj,ci)=(-x0+idx(cj,ci))/Dt;
              vp(cj,ci)=(-y0+idy(cj,ci))/Dt;
              xp(cj,ci)=(ii+(M/2)-1);
              yp(cj,ci)=(jj+(N/2)-1);
              SnR(cj,ci)=snr;
              Pkh(cj,ci)=R(max_y1,max_x1);
            else
              up(cj,ci)=NaN; vp(cj,ci)=NaN; SnR(cj,ci)=NaN; Pkh(cj,ci)=0; 
              xp(cj,ci)=(ii+(M/2)-1);
              yp(cj,ci)=(jj+(N/2)-1);
            end
            ci=ci+1; 
        else
          xp(cj,ci)=(M/2)+ii-1;
          yp(cj,ci)=(N/2)+jj-1;
          up(cj,ci)=NaN; vp(cj,ci)=NaN;
          SnR(cj,ci)=NaN; Pkh(cj,ci)=NaN;ci=ci+1;
        end  
    end 
    % disp([num2str((cj-1)*(ci)+ci-1) ' vectors in ' num2str(toc) ' seconds'])
    fprintf('\r No. of vectors: %d', ((cj-1)*(ci)+ci-1) -sum(isnan(up(:))))
    fprintf(', Seconds taken: %f', toc);
    cj=cj+1;
end

% now we inline the function XCORRF2 to shave off some time.
function c = xcorrf2(a,b,pad)
%  c = xcorrf2(a,b)
%   Two-dimensional cross-correlation using Fourier transforms.
%       XCORRF2(A,B) computes the crosscorrelation of matrices A and B.
%       XCORRF2(A) is the autocorrelation function.
%       This routine is functionally equivalent to xcorr2 but usually faster.
%       See also XCORR2.

%       Author(s): R. Johnson
%       $Revision: 1.0 $  $Date: 1995/11/27 $

  if nargin==2
    pad='yes';
  end
  
  [ma,na] = size(a);
%   if nargin == 1
%     %       for autocorrelation
%     b = a;
%   end
  [mb,nb] = size(b);
  %       make reverse conjugate of one array
  b = conj(b(mb:-1:1,nb:-1:1));
  if strcmp(pad,'yes'); 
    %       use power of 2 transform lengths
    mf = 2^nextpow2(ma+mb);
    nf = 2^nextpow2(na+nb);
    at = fft2(b,mf,nf);
    bt = fft2(a,mf,nf);
  elseif strcmp(pad,'no');
    at = fft2(b);
    bt = fft2(a);
  else
    disp('Wrong input to XCORRF2'); return
  end
  %       multiply transforms then inverse transform
  c = ifft2(at.*bt);
  %       make real output for real input
  if ~any(any(imag(a))) & ~any(any(imag(b)))
    c = real(c);
  end
  if strcmp(pad,'yes');
    %  trim to standard size
    c(ma+mb:mf,:) = [];
    c(:,na+nb:nf) = [];
  elseif strcmp(pad,'no');
    c=(c(1:end-1,1:end-1));
    
    %    c(ma+mb:mf,:) = [];
    %    c(:,na+nb:nf) = [];
  end
  
  
