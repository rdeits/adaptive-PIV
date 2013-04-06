function [hu,hv]=localfilt(x,y,u,v,threshold,varargin)

% [NewU,NewV]=localfilt(x,y,u,v,threshold,method,kernelsize,mask)
%  
% This function is a filter that will remove vectors that deviate from
% the median or the mean of their surrounding neighbors by the factor
% THRESHOLD times the standard deviation of the neighbors. 
%
% METHOD (optional) should be either 'median' or 'mean'. Default is
% 'median'.
%
% KERNELSIZE is optional and is specified as number, typically 3 or 5
% which defines the number of vectors contributing to the median or mean
% value of each vector. 
%
% MASK should be applied to save calculation time. LOCALFILT is relatively 
% slow on large matrices and exlcuding "non-interesting" regions with MASK
% can increase speed in some cases.
% 
% 
% See also: matpiv, snrfilt, globfilt, peakfilt, mask


% 1999 - 2002 , jks@math.uio.no
% For use with MatPIV 1.6
%
% Copyright J.K.Sveen (jks@math.uio.no)
% Dept. of Mathematics, Mechanics Division, University of Oslo, Norway
% Distributed under the Gnu General Public License
%
% Time: 10:41, Jan 17 2002

IN=zeros(size(u));

if nargin < 5
    disp(' Not enough input arguments!'); return
end
if ischar(threshold)
    disp(' Please give threshold as numeric input'); return
end
if nargin > 5
    tm=cellfun('isclass',varargin,'double'); pa=find(tm==1); 
    if ~isempty(pa), m=cat(1,varargin{pa}); else, m=3; end 
    if any(strcmp(varargin,'median'))
        method='mnanmedian'; stat='median'; ff=1;
    elseif any(strcmp(varargin,'mean'))
        method='mnanmean'; stat='mean'; ff=2;
    end  
    if ~any(strcmp(varargin,'mean')) & ~any(strcmp(varargin,'median'))
        method='mnanmedian'; stat='median';
    end
    
    if nargin==8, 
        maske=varargin{end}; 
        if ischar(maske) & ~isempty(maske), maske=load(maske); maske=maske.maske; end
        if ~isempty(maske)
            for ii=1:length(maske) 
                IN2=inpolygon(x,y,maske(ii).idxw,maske(ii).idyw);
                IN=[IN+IN2];
            end
        else IN=zeros(size(u)); 
        end, 
    end
    
end
if nargin==5
    m=3; method='mnanmedian'; stat='median';
end

nu=zeros(size(u)+2*floor(m/2))*nan;
nv=zeros(size(u)+2*floor(m/2))*nan;
nu(floor(m/2)+1:end-floor(m/2),floor(m/2)+1:end-floor(m/2))=u;
nv(floor(m/2)+1:end-floor(m/2),floor(m/2)+1:end-floor(m/2))=v;

INx=zeros(size(nu));
INx(floor(m/2)+1:end-floor(m/2),floor(m/2)+1:end-floor(m/2))=IN;

prev=isnan(nu); previndx=find(prev==1); 
U2=nu+i*nv; teller=1; [ma,na]=size(U2); histo=zeros(size(nu));
histostd=zeros(size(nu));hista=zeros(size(nu));histastd=zeros(size(nu));
fprintf([' Local ',stat,' filter running: '])

for ii=m-1:1:na-m+2  
    for jj=m-1:1:ma-m+2
        if INx(jj,ii)~=1
            
            tmp=U2(jj-floor(m/2):jj+floor(m/2),ii-floor(m/2):ii+floor(m/2)); 
            tmp(ceil(m/2),ceil(m/2))=NaN;
            if ff==1
                usum=mnanmedian(tmp(:));
            elseif ff==2
                usum=mnanmean(tmp(:));
            end
            histostd(jj,ii)=mnanstd(tmp(:));
        else
            usum=nan; tmp=NaN; histostd(jj,ii)=nan;
        end
%         u1=real(usum).^2 - real(U2(jj,ii)).^2;
%         v1=imag(usum).^2 - imag(U2(jj,ii)).^2;
%         
%         histo(jj,ii)=u1+i*v1;
        histo(jj,ii)=usum;
        %histostd(jj,ii)=mnanstd(real(tmp(:))) + i*mnanstd(imag(tmp(:)));
        
        %th1=angle(usum); th2=angle(U2(jj,ii));
        %if th1<0, th1=2*pi+th1; end
        %if th2<0, th2=2*pi+th2; end
        %hista(jj,ii)=(th1-th2);
        %if hista(jj,ii)<0, hista(jj,ii)=2*pi+hista(jj,ii); end 
        %histastd(jj,ii)=mnanstd(abs(angle(tmp(:))));
    end
    fprintf('.')
    
end

%%%%%%%% Locate gridpoints with a higher value than the threshold 

%[cy,cx]=find((real(histo)>threshold*real(histostd) | ...
%    imag(histo)>threshold*imag(histostd)));
[cy,cx]=find( ( real(U2)>real(histo)+threshold*real(histostd) |...
    imag(U2)>imag(histo)+threshold*imag(histostd) |...
    real(U2)<real(histo)-threshold*real(histostd) |...
    imag(U2)<imag(histo)-threshold*imag(histostd) ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for jj=1:length(cy)
    %uv2(jj)=u(cy(jj),cx(jj)); vv2(jj)=v(cy(jj),cx(jj));
    %xv2(jj)=x(cy(jj),cx(jj)); yv2(jj)=y(cy(jj),cx(jj));
    % Now we asign NotANumber (NaN) to all the points in the matrix that
    % exceeds our threshold.
    nu(cy(jj),cx(jj))=NaN;  nv(cy(jj),cx(jj))=NaN;
end

rest=length(cy);

rest2=sum(isnan(u(:)))-sum(prev(:));
fprintf([num2str(rest),' vectors changed'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we check for NaN's and interpolate where they exist
if any(strcmp(varargin,'interp'))
    if any(isnan(u(:)))
        [nu,nv]=naninterp(nu,nv);
    end
end
hu=nu(ceil(m/2):end-floor(m/2),ceil(m/2):end-floor(m/2));
hv=nv(ceil(m/2):end-floor(m/2),ceil(m/2):end-floor(m/2));
fprintf('.\n')



