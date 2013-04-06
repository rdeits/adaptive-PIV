function y = mnanstd(x,N)
% MNANSTD NaN protected standard deviation.
%   MNANSTD(X) returns the standard deviation treating NaNs as missing values.
%   For vectors, MNANSTD(X) is the standard deviation value of the non-NaN
%   elements in X.  For matrices, MNANSTD(X) is the 2-D standard deviation 
%   value, ignoring NaNs. 
%   MNANSTD(X,0) normalizes by (N-1), MNANSTD by default normalizes by N.
%
%   See also NANMEAN, NANSTD, NANMIN, NANMAX, NANSUM.

%   by John Peter Acklam, jacklam@math.uio.no
%   minor modification by Kristian Sveen, jks@math.uio.no

if nargin==1
    N=1;
elseif nargin==2
    if N~=1 & N~=0
        disp('N should be 0 or 1.'); return
    end
end 

if isreal(x)
    ii = ~isnan(x);
    if any(ii)
        y = std(x(ii),N);
    else
        y = NaN;
    end
else
    ii = ~isnan(x);
    if any(ii)
        if length(real(x(ii)))>=2
            oy=std([real(x(ii)) imag(x(ii))],N);    
           y = oy(1)+i*oy(2);
       else
           y = 0;
       end
    else
        y = NaN;
    end
end