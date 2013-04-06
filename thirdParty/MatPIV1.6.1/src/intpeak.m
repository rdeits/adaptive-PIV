function [x0,y0]=intpeak(x1,y1,R,Rxm1,Rxp1,Rym1,Ryp1,method,N)

% INTPEAK - interpolate correlation peaks in PIV
%
% function [x0,y0]=intpeak(x1,x2,x3,y1,y2,y3,method,N)
% METHOD = 
% 1 for centroid fit, 
% 2 for gaussian fit, 
% 3 for parabolic fit
% x1 and y1 are maximal values in respective directions.
% N is interrogation window size. N is either 1x1 or 1x2
%
% This is a subfunction to MATPIV

% Time stamp: 12:32, Apr. 14, 2004.
%
% Copyright 1998-2004, J. Kristian Sveen, 
% jks@math.uio.no/jks36@damtp.cam.ac.uk
% Dept of Mathmatics, University of Oslo/ 
% DAMTP, Univ. of Cambridge, UK
%
% Distributed under the GNU general public license.
%
% For use with MatPIV 1.6 and subsequent versions

if length(N)==2
    M=N(1); N=N(2);
else
    M=N;
end

if any(find(([R Rxm1 Rxp1 Rym1 Ryp1])==0))
    % to avoid Log of Zero warnings
    method=1;
end

if method==1  
    x01=(((x1-1)*Rxm1)+(x1*R)+((x1+1)*Rxp1)) / (Rxm1+ R+Rxp1);
    y01=(((y1-1)*Rym1)+(y1*R)+((y1+1)*Ryp1)) / (Rym1+ R+Ryp1);
    x0=x01-(M);
    y0=y01-(N);
elseif method==2  
    x01=x1 + ( (log(Rxm1)-log(Rxp1))/( (2*log(Rxm1))-(4*log(R))+(2*log(Rxp1))) );
    y01=y1 + ( (log(Rym1)-log(Ryp1))/( (2*log(Rym1))-(4*log(R))+(2*log(Ryp1))) );  
    x0=x01-(M);
    y0=y01-(N);  
elseif method==3
    x01=x1 + ( (Rxm1-Rxp1)/( (2*Rxm1)-(4*R)+(2*Rxp1)) );
    y01=y1 + ( (Rym1-Ryp1)/( (2*Rym1)-(4*R)+(2*Ryp1)) ); 
    x0=x01-(M);
    y0=y01-(N);
    
    
else
    
    disp(['Please include your desired peakfitting function; 1 for',...
	  ' 3-point fit, 2 for gaussian fit, 3 for parabolic fit'])
    
end


x0=real(x0);
y0=real(y0);
