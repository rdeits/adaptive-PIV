function piv_error(imageA, imageB, X1, Y1, U1, V1, X2, Y2, U2, V2)
% Show the deviation of PIV results X2 Y2 U2 V2 from reference results X1 Y1 U1 V1

U_interp = interp2(X2, Y2, U2, X1, Y1);
V_interp = interp2(X2, Y2, V2, X1, Y1);

figure(1)
subplot 221
contourf(X1, Y1, U1)
caxis([-5, 5])
colorbar

subplot 222
contourf(X1, Y1, V1)
caxis([-5, 5])
colorbar

subplot 223
contourf(X1, Y1, U_interp)
caxis([-5, 5])
colorbar

subplot 224
contourf(X1, Y1, V_interp)
caxis([-5, 5])
colorbar

figure(2)
subplot 121
contourf(X1, Y1, (U_interp - U1));
caxis([-1, 1])
axis equal
colorbar

subplot 122
contourf(X1, Y1, (V_interp - V1));
caxis([-1, 1])
axis equal
colorbar

hold off