dx = 1.;
dy = 1.;

x_offset = 0.35;
y_offset = 0.5;

x = -3:dx:3;
y = -3:dy:3;
x = x + x_offset;
y = y + y_offset;

[X Y]=meshgrid(y,x);

G = exp(-(X.^2+Y.^2));
surf(G)

[ ip_x, ip_y, SNR, MMR, PPR ] = func_findpeak2( G, 2 )

