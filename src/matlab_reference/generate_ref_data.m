function generate_ref_data(directory)

%make list of all images in directory
dirPath = ['../../data/vort_sim/'];
allImages = [dir([dirPath,'*.png']); 
    dir([dirPath,'*.tif']); 
    dir([dirPath,'*.jpg']); 
    dir([dirPath,'*.bmp'])];

%window size and overlap factor
Ws = 64;
% OF = 63/64;
% OF = .75;
OF = .875;

i = 1;

%read image pair
try
    imageA = rgb2gray(double(imread([dirPath,allImages(2*i-1).name])));
    imageB = rgb2gray(double(imread([dirPath,allImages(2*i).name])));
catch
    imageA = double(imread([dirPath,allImages(2*i-1).name]));
    imageB = double(imread([dirPath,allImages(2*i).name]));
end

%run chosen PIV algorithm
tic
[X,Y,U,V,edgeSize] = normalPIV1(imageA,imageB, Ws, OF);
edgeX = X;
edgeY = Y;
toc

%display final image
figure(i)
imshow(uint8(imageA/2));
hold on;
imshow(uint8(imageB/2));
quiver(X,Y,U,V,'Color','yellow');

%draw edges
% drawFactor = 0.3;
% for j = 1:length(edgeX),
%     if rand(1)<drawFactor,
%         rectangle('Position',[edgeX(j)-floor(edgeSize(j)/2),edgeY(j)-floor(edgeSize(j)/2),edgeSize(j),edgeSize(j)],'EdgeColor','red');
%     end
% end
hold off;

save('reference_data.mat')
end