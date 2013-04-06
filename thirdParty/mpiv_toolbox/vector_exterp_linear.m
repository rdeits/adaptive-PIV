function[ uo ] = vector_interp_linear( ui )
%========================================================================
%
% version 1.1
%
%
% 	vector_exterp_linear
%
%
% Description:
%
%	Exterpolate vectors at the edge by linear interpolation
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
%       1.11    2009/07/01 BSD License is applied
%	1.1	2003/04/07 Add linear expolation
%	1.0	2003/04/02 Fist version
%
%========================================================================

uo = ui;
mx = size(ui,1);
my = size(ui,2);

% interal call
% i_opt = 1 : linear expolation
%         2 : continue fixed value
i_opt = 1;

if i_opt == 1

  % top side
  for ix=2:mx-1
    uo(ix, 1) = 2*ui(ix,2) - ui(ix, 3);
  end

  % bottom side
  for ix=2:mx-1
    uo(ix,my) = 2*ui(ix,my-1) - ui(ix,my-2);
  end

  % left side
  for iy=2:my-1
    uo(1,iy) = 2*ui(2,iy) - ui(3,iy);
  end

  % right side
  for iy=2:my-1
    uo(mx,iy) = 2*ui(mx-1,iy) - ui(mx-2,iy);
  end

elseif i_opt == 2

  % top side
  for ix=2:mx-1
    uo(ix, 1) = ui(ix,2);
  end

  % bottom side
  for ix=2:mx-1
    uo(ix,my) = ui(ix,my-1);
  end

  % left side
  for iy=2:my-1
    uo(1,iy) = ui(2,iy);
  end

  % right side
  for iy=2:my-1
    uo(mx,iy) = 2*ui(mx-1,iy) - ui(mx-2,iy);
  end

end


if i_opt == 1

  % left-top corner
  uo(1,1) = ( ui(1,2) + ui(2,1) + ui(2,2) )/3;

  % right-top corner
  uo(mx,1) = ( ui(mx-1,2) + ui(mx-1,1) + ui(mx,2) )/3;

  % left-bottom corner
  uo(1,my) = ( ui(2,my-1) + ui(1,my-1) + ui(2,my) )/3;

  % right bottom corner
  uo(mx,my) = ( ui(mx-1,my-1) +ui(mx-1,my) + ui(mx,my-1)  )/3;

elseif i_opt == 2

  % left-top corner
  uo(1,1) = ui(2,2);

  % right-top corner
  uo(mx,1) = ui(mx-1,2);

  % left-bottom corner
  uo(1,my) = ui(2,my-1);

  % right bottom corner
  uo(mx,my) = ui(mx-1,my-1);

end
