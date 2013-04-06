function[ uo ] = vector_interp_linear( ui )
%========================================================================
%
% version 2.0
%
%
% 	vector_interp_linear
%
%
% Description:
%
%	Interpolate NaN vector by linear interpolation
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
%	2.0	2003/04/02 add one more point
%	1.0	2002/09/11 First version
%
%========================================================================

uo = ui;
mx = size(ui,1);
my = size(ui,2);

% main
for iy=2:my-1
  for ix=2:mx-1
    if isnan( ui(ix,iy) ) == 1
      uo(ix,iy) = ( ui(ix+1,iy) + ui(ix-1,iy) + ui(ix,iy+1) + ui(ix,iy-1) )/4;
    end
  end
end

% top side
for ix=2:mx-1
  if isnan( ui(ix,1) ) == 1
    uo(ix, 1) = ui(ix, 2);
  end
end

% bottom side
for ix=2:mx-1 
  if isnan( ui(ix,my) ) == 1
   uo(ix,my) = ui(ix,my-1);
  end
end

% left side
for iy=2:my-1
  if isnan( ui(1,iy) ) == 1
    uo( 1,iy) = ui( 2,iy+1);
  end
end

% right side
for iy=2:my-1
  if isnan( ui(mx,iy) ) == 1
    uo(mx,iy) = ui(mx-1,iy);
  end
end

% left-top corner
if isnan( ui(1,1) ) == 1  
  uo(1,1) = ui(2,2);
end

% right-top corner
if isnan( ui(mx,1) ) == 1  
  uo(mx,1) = ui(mx-1,2);
end

% left-bottom corner
if isnan( ui(1,my) ) == 1  
  uo(1,my) = ui(2,my-1);
end

% right bottom corner
if isnan( ui(mx,my) ) == 1  
  uo(mx,my) = ui(mx-1,my-1);
end

