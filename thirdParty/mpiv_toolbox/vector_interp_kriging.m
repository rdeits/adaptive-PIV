function[ uo, MSE ] = vector_interp_kriging( ui )
%========================================================================
%
% version 0.52
%
%
% 	vector_interp_kriging
%
%
% Description:
%
%	Interpolate NaN vector by kriging interpolation
%         Correlation function	: Exponential
%         Regression model	: First order polynomial
%
% Requirements:
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
%       0.53    2009/07/01 BSD License is applied
%	0.52	2003/06/12 Minor bug has been fixed
%	0.50	2003/06/12 Minor bug has been fixed
%	0.30	2003/06/12 Correlation function has been changed to Gaussian.
%	0.20	2003/06/10 Correlation function has been changed to Exp.
%	0.10	2003/06/10 First version
%
%========================================================================

% <===== Input for professional use				<=====
%      can be replaced with other appropriate values

% i_plot = 1        check plotting
%        = other    no plotting
i_plot = 9;

% parameters for kriging
theta = [1 1];
lob   = [1e-1 1d-1];
upb   = [20 20];

% =====> End of input for professional use			======>

mx = size(ui,1);
my = size(ui,2);
nv = mx*my;

n = 0;
for ix=1:mx
    for iy=1:my
        if isnan(ui(ix,iy))==0
          n = n + 1;
          S(n,1) = ix;
          S(n,2) = iy;
          Y(n,1) = ui(ix,iy);
        end
    end
end

if n >= 2
  [dmodel,perf] = dacefit( S, Y, @regpoly2, @corrgauss, theta );

  n = 0;
  for ix=1:mx
    for iy=1:my
      n = n + 1;
      X(n,1) = ix;
      X(n,2) = iy;
    end
  end

  [YX MSE] = predictor( X, dmodel );
  uo = reshape( YX, my, mx );

else

  uo = ui;

end

uo = uo';

%
% --- plot for test
%

if i_plot == 1
    figure(1)
    X1 = reshape(X(:,1),my,mx);
    X2 = reshape(X(:,2),my,mx);
    MSE = reshape(MSE,my,mx);

    subplot(2,1,1)
    surf(X1,X2,uo');
    hold on
    plot3(S(:,1),S(:,2),Y,'.r','MarkerSize',10);
    hold off
    subplot(2,1,2)
    surf(X1,X2,MSE);
end
