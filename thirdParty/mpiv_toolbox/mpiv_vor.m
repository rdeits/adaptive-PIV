function [vor] = mpiv_vor( u, v, i_plot)
%
% This program is to calculate and plot vorticity using PIV.
% The grid size dx and dy is assumed to be 1.
% The gride size can be changed below.
%
% Input:
%   u, v    velocity component
%   i_plot  1: plot result
%           otherwise: no plotting
%
%
%======================================================================
%
% Terms:
%
%       Distributed under the terms of the terms of the BSD License
%
%=======================================================================

%  input the mesh side: ========================
dx = 1;
dy = 1;
i_smooth = 1;      % to smooth the vorticity
% ==============================================

n_x = size(u, 2);
n_y = size(u, 1);

%inside boundary
for i=2:n_x-1
   for j=2:n_y-1
      dxdy = 4 * dx * dy;
      circ1 = 0.5 * dx * (u(j+1,i-1) + 2 * u(j+1,i) + u(j+1,i+1));
      circ2 = 0.5 * dx * (u(j-1,i-1) + 2 * u(j-1,i) + u(j-1,i+1));
      circ3 = 0.5 * dy * (v(j-1,i+1) + 2 * v(j,i+1) + v(j+1,i+1));
      circ4 = 0.5 * dy * (v(j-1,i-1) + 2 * v(j,i-1) + v(j+1,i-1));
      vor(j,i) = (circ1 - circ2 + circ3 - circ4) / dxdy;
   end
end

%top and bottom boundaries   
j=1;
for i=2:n_x-1
   vor(j,i) = vor(j+1,i);
end

j=n_y;
for i=2:n_x-1
   vor(j,i) = vor(j-1,i);
end

%left and right boundaries
i=1;
for j=2:n_y-1
   vor(j,i) = vor(j,i+1);
end

i=n_x;
for j=2:n_y-1
   vor(j,i) = vor(j,i-1);
end

%four corners
i=1;
j=1;
vor(j,i) = (vor(j+1,i) + vor(j,i+1)) / 2;

i=1;
j=n_y;
vor(j,i) = (vor(j-1,i) + vor(j,i+1)) / 2;

i=n_x;
j=1;
vor(j,i) = (vor(j+1,i) + vor(j,i-1)) / 2;

i=n_x;
j=n_y;
vor(j,i) = (vor(j-1,i) + vor(j,i-1)) / 2;

% smoothing data
if i_smooth ==1

  kern = [1  1  1
          1  8  1
          1  1  1];
  vor = func_smooth(vor);
end

vor_max=max(max(vor))
vor_min=min(min(vor))

for j = 1: n_y
   for i = 1:n_x
     if vor(j,i) == vor_max
        ymax = j;
        xmax = i;
     end
     if vor(j,i) == vor_min
        ymin = j;
        xmin = i;
     end
   end
end   

if i_plot ==1
  figure
  contour(1:n_x, 1:n_y, vor);
  colorbar
  xlabel('x axis')
  ylabel('y axis')
  title('Vorticity')
  set(gca,'YDir','reverse')
end

