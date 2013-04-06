function[ uo ] = vector_interp_NaN( ui )
%========================================================================
%
% version 2.0
%
%
% 	vector_interp_NaN
%
%
% Description:
%
%	Interpolate sequential NaN vectors using mean value and median filter
%       + Specific
%	  - 
%
% Variables:
%
%	Input;
%	ui		velocity vector
%			
%	Output;
%	uo		output velocity
%
%======================================================================
%
% Terms:
%
%       Distributed under the terms of the terms of the BSD License
%
% Copyright:
%
%       Nobuhito Mori
%           Disaster Prevention Research Institue
%           Kyoto University, JAPAN
%           mori@oceanwave.jp
%
%======================================================================
%
% Update:
%       2.01    2009/07/01 BSD License is applied
%	2.0	2003/04/03 Use different algorithm (rewrite completely)
%	1.0	2003/04/03 First version
%
%========================================================================

mx = size(ui,1);
my = size(ui,2);
uy = ui;
uo = ui;

[ ut ] = vector_interp_linear( ui );

u_mean = 0;
% cal mean velocity
n = 0;
for iy=1:my
  for ix=1:mx
    if isnan( ui(ix,iy) ) ~= 1
      n = n + 1;
      u_mean= u_mean + ui(ix,iy);
    end
  end
end
u_mean = u_mean/n;

% replace NaN by u_mean
for iy=1:my
  for ix=1:mx
    if isnan( ui(ix,iy) ) == 1
      ut(ix,iy) = u_mean;
    end
  end
end

[ ut ] = medfilt2( ut, [3, 3] );

ut( 1, 1) = ut(   2,   2);
ut(mx, 1) = ut(mx-1,   2);
ut( 1,my) = ut(   2,my-1);
mt(mx,my) = ut(mx-1,my-1);

% compare to ui and uo
for iy=1:my
  for ix=1:mx
    if isnan( ui(ix,iy) ) == 1
      uo(ix,iy) = ut(ix,iy);
    end
  end
end
