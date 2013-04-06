function [su]=msmooth(U,hin,n,varargin)
  
% MSMOOTH - smooth noisy data
%
% u=msmooth(U) will smooth U using a weight-matrix h=1/9*ones(3);
% u=msmooth(U,h) will smooth U using a user defined weight-matrix, h.
% u=msmooth(U,method,n) will smooth U using one of the following
% methods (as defined in FSPECIAL): 
% 'gaussian','sobel','prewitt','laplacian','log','average','unsharp'
% 
% u=msmooth(u,'gaussian',5) will smooth u using a 5*5 gaussian kernel.
%
% msmooth uses the functions FILTER2 and FSPECIAL (image toolbox) to
% perform smoothing of noisy data.
%
% Additionally a simple threepoint kernel is available using a kernel
% h=[0 0.25 0;0.25 0.5 0.25;0 0.25 0]; in the interior of the
% velocity field and h=[0.75 0.5 -0.25;0.5 0 0;-0.25 0 0]; on the
% borders of the velocity field. This is the only of the kernels that
% treats the borders properly. For three-point kernel type:
% u=msmooth(u,'threepoint');
% 
% 
%
  
% For use with MatPIV v. 1.6 and subsequent versions
% Copyright J.K.Sveen (jks@math.uio.no), 2001-2002
%
% Distributed under the terms of the terms of the 
% GNU General Public License
%
% Time Stamp: 11:23, February 21, 2002, 
% addition of looping, Dec 4 2002

% locate masked-out-regions  
inan=isnan(U);
%

if nargin==1 
    h = (1/9)*ones(3); su = filter2(h,U,'same'); 
elseif nargin>1
    if nargin==2, n=3; end
    if ischar(hin)
      switch hin
       case {'gaussian','sobel','prewitt','laplacian','log','average','unsharp'}
	h=fspecial(hin,n);
	su = filter2(h,U,'same');
       case 'threepoint'
	h=[0 0.25 0;0.25 0.5 0.25;0 0.25 0]
	if nargin>3
	  if strcmp(n,'loop')
	    tel=1; slutt=varargin{1};su=U;
	    while tel<=slutt
	      su = filter2(h,su,'same');
	      tel=tel+1;
	      inx=find(isnan(su) & ~isnan(U)); su(inx)=U(inx);
	    end
	    % figure, spy(su(~isnan(su)))
	  else
	    disp('Error!')
	  end
	else 
	  su = filter2(h,U,'same');
	end
	%inan(4:end-3,4:end-3)=1;
	
	%%%%%%%%%%%%%UNDER ARBEID 21.2.2002 
	% Få inkorporert masken i edge-modifikasjonen. Dette virker
        % ikke per desember 2002.
	%
	%utemp=U; utemp(inan)=NaN;
	%h=[0.75 0.5 -0.25;0.5 0 0;-0.25 0 0];
	%su2 = filter2(h,U,'same');
	%su2(2:end-1,2:end-1)=su; su=su2;
       otherwise
	disp('Unknown method.')
      end
    elseif ~ischar(hin)
      if size(hin,1)==size(hin,2)
	h=hin;
	su = filter2(h,U,'same');
      else
	disp('Smoothing kernel should be symmetric'); return
      end
    else
      disp('Unknown weight-function');return
    end
end
% add the borders
inx=find(isnan(su) & ~isnan(U)); su(inx)=U(inx);

