function [V,U] = crossCorrelation1(frameA,frameB)

%a little housekeeping
frameA = double(frameA);
frameB = double(frameB);
[Arows,Acols] = size(frameA);
%do cross-correlation
res = xcorr2(frameB,frameA);

%%gpu-based cross-correlation alternative
% tic;
% frameA = gpuArray(frameA);
% frameB = gpuArray(frameB);
% res = xcorr2(frameB,frameA);
% resG = gather(res);
% toc

%gaussian smoothing on the result
h = ceil(Arows/10);
if h<2,
    h = 2;
end
sig = floor(h/2);
G = fspecial('gaussian',[h,h],sig);
resG = imfilter(res,G,'same');

%find the maximum
[maxR,maxC] = find(resG == max(max(resG)));
maxR = maxR(1);
maxC = maxC(1);

%find the displacement
[midR,midC] = size(resG);
midR = ceil(midR/2);
midC = ceil(midC/2);
V = maxR-midR;
U = maxC-midC;

end