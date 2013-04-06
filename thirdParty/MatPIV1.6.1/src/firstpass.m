function [xx,yy,datax,datay]=firstpass(A,B,N,ol,counter,idx,idy,maske)

% function [x,y,datax,datay]=firstpass(A,B,M,N,ol,counter,idx,idy,maske)
%
% This function is used in conjunction with the MULTIPASS.M run-file.
% Inputs are allocated from within MULTIPASS.

% 1999 - 2001, J. Kristian Sveen (jks@math.uio.no)
% For use with MatPIV 1.5, Copyright
% Distributed under the terms of the GNU - GPL license
% timestamp: 21.20, 20 Feb 2001

if length(N)==1
    M=N;winsize=[M N]; 
elseif length(N)==2
    M=N(1); N=N(2); winsize=[M N]; 
end
overlap=ol; [sy,sx]=size(A);
if nargin < 6 | isempty(idx) | isempty(idy)
    idx=zeros(floor(sy/(N*(1-ol))),floor(sx/(M*(1-ol))));
    idy=zeros(floor(sy/(N*(1-ol))),floor(sx/(M*(1-ol))));
end
x=zeros(ceil((size(A,1)-N)/((1-overlap)*N))+1, ...
    ceil((size(A,2)-M)/((1-overlap)*M)) +1);
y=x; u=x; v=x; 
% change . october 2001, weight matrix added.
% W=weight('cosn',[M N],100);
if nargin==8, 
    if ~isempty(maske)
        IN=zeros(size(maske(1).msk));
        for i=1:length(maske)
            IN=IN+double(maske(i).msk);
        end
    else 
        IN=zeros(size(A)); 
    end,
elseif nargin<8
    IN=zeros(size(A)); 
end

cj=1;tic
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
            
            C=A(jj:jj+N-1,ii:ii+M-1);   
            D=B(jj+idy(cj,ci):jj+N-1+idy(cj,ci),ii+idx(cj,ci):ii+M-1+idx(cj,ci));
%             D=eval('B(jj+idy(cj,ci):jj+N-1+idy(cj,ci),ii+idx(cj,ci):ii+M-1+idx(cj,ci) )',...
%                 'B(jj:jj+N-1,ii:ii+M-1)');
%             if D==B(jj:jj+N-1,ii:ii+M-1)
%                 idx(cj,ci)=0; idy(cj,ci)=0;
%             end
            C=C-mean(C(:)); D=D-mean(D(:)); %C(C<0)=0; D(D<0)=0;
            stad1=std(C(:)); stad2=std(D(:)); 
            % Apply weight function by uncommenting below
            %C=C.*W; %D=D.*W;
            %
            if stad1==0, stad1=nan;end
            if stad2==0, stad2=nan; end

            %%%%%%%%%%%%%%%%%%%%%%%Calculate the normalized correlation:   
            R=xcorrf2(C,D)/(N*M*stad1*stad2);
            %%%%%%%%%%%%%%%%%%%%%% Find the position of the maximal value of R
            if size(R,1)==(N-1)
              [max_y1,max_x1]=find(R==max(R(:)));
            else
              [max_y1,max_x1]=find(R==max(max(R(0.5*N+2:1.5*N-3,0.5*M+2:1.5*M-3))));
            end
            
            if length(max_x1)>1
              max_x1=round(sum(max_x1.*([1:length(max_x1)]'))./sum(max_x1));
              max_y1=round(sum(max_y1.*([1:length(max_y1)]'))./sum(max_y1));
            elseif isempty(max_x1)
              idx(cj,ci)=nan; idy(cj,ci)=nan; max_x1=nan; max_y1=nan;
            end
            %%%%%%%%%%%%%%%%%%%%%% Store the displacements in variable datax/datay
            datax(cj,ci)=-(max_x1-(M))+idx(cj,ci);
            datay(cj,ci)=-(max_y1-(N))+idy(cj,ci);
            xx(cj,ci)=ii+M/2; yy(cj,ci)=jj+N/2;
            ci=ci+1;
        else
            xx(cj,ci)=ii+M/2; yy(cj,ci)=jj+N/2;
            datax(cj,ci)=NaN; datay(cj,ci)=NaN; ci=ci+1;
        end  
    end
    fprintf('\r No. of vectors: %d', ((cj-1)*(ci)+ci-1)-sum(isnan(datax(:))))
    fprintf(' , Seconds taken: %f', toc);
    cj=cj+1;
end
disp('.')


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
  %if nargin == 1
  %  %       for autocorrelation
  %  b = a;
  %end
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
