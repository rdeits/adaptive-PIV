function[ uo, MSE ] = vector_interp_kriging( ui )
%========================================================================
%
% version 0.63
%
%
% 	vector_interp_kriging_local
%
%
% Description:
%
%	Interpolate NaN vector by kriging interpolation
%   Local filtering
%         Correlation function	: Exponential
%         Regression model	: First order polynomial
%
%
% Requirements:
%
%   - vector_interp_kriging.m
%
%	This program requires DACE, Kriging Toolbox, developed by
%   S.N. Lophaven, H.B. Nielsen and J. Sondergaard
%   at Technical University of Denmark
%
% Variables:
%
%	Input;
%	ui		velocity vector
%			
%	Output;
%	uo		output velocity
%	MSE		output estimated MS error
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
%       0.71    2009/07/01 BSD License is applied
%       0.70    2009/07/01 BSD License is applied
%	0.63	2004/12/02 Minor bug has been fixed
%	0.62	2003/07/02 Minor bug has been fixed
%	0.61	2003/06/26 Minor error has been revised.
%	0.60	2003/06/20 Variable window size has bee adopted.
%	0.55	2003/06/16 Check for small number of data has been added.
%	0.50	2003/06/12 Minor bug has been fixed
%	0.30	2003/06/12 Correlation function has been changed to Gaussian.
%	0.20	2003/06/10 Correlation function has been changed to Exp.
%	0.10	2003/06/10 First version
%
%========================================================================

% <===== Input for professional use				<=====
%      can be replaced with other appropriate values

% window size for kriging fiter. This must be odd number
nw_start = 5;
nw_max   = 9;

% number of minimum point for interpolation
np_min = 15;

% =====> End of input for professional use			======>

if max(max(isnan(ui))) == 1

%
% --- initial setup
%

mx = size(ui,1);
my = size(ui,2);
mv = mx*my;

nwh_start = floor(nw_start/2);

%
% ---- main part
%

uo = ui;

if ( mx >= nw_start ) & ( my >= nw_start )

for ix=1:mx
  for iy=1:my
    if isnan(ui(ix,iy)) == 1

      i_flag = 0;
      nw     = nw_start;
      nw_h   = nwh_start;

      while i_flag == 0
        % making target area to interpolate
        lx1 = ix - nw_h;
        lx2 = ix + nw_h;
        ly1 = iy - nw_h;
        ly2 = iy + nw_h;
        jx  = nw_h + 1;
        jy  = nw_h + 1;
            
        if lx1 < 1
	  jx  = jx  - (1-lx1);
          lx2 = lx2 + (1-lx1);
          lx1 = 1;
        end
        if lx2 > mx
	  jx  = jx  + (lx2-mx);
          lx1 = lx1 - (lx2-mx);
          lx2 = mx;
        end
	if ly1 < 1
	  jy  = jy  - (1-ly1);
          ly2 = ly2 + (1-ly1);
          ly1 = 1;
        end
	if ly2 > my
	  jy  = jy  + (ly2-my);
          ly1 = ly1 - (ly2-my);
          ly2 = my;
        end

	clear fi;
	if (lx1>=1) & (ly1>=1)
          fi = ui(lx1:lx2,ly1:ly2);
        else
          fi = NaN;
        end
        [m,n] = func_countNaN( fi );
        if n < np_min
  	  nw   = nw   + 2;
  	  nw_h = nw_h + 1;
        else 
  	  i_flag = 1;
        end
        if nw > nw_max
  	  i_flag = 9;
        end
      end
       
      % kriging interpolation
      if i_flag == 1
        [ fo ] = vector_interp_kriging( fi );
        uo(ix,iy) = fo(jx,jy);
      else
        uo(ix,iy) = NaN;
      end

    end
  end
end

else

  uo = vector_interp_kriging( ui );

end

%
% --- for the case ui does not have NaN vector
%

else

  uo = ui;

end
