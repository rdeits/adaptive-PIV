function PIVscaffold1()

%make list of all images in directory
dirPath = ['../../data/vort_sim/'];
allImages = [dir([dirPath,'*.png']); 
    dir([dirPath,'*.tif']); 
    dir([dirPath,'*.jpg']); 
    dir([dirPath,'*.bmp'])];

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
    [X,Y,U,V,edgeSize] = fixedPointPIV(imageA,imageB);
    edgeX = X;
    edgeY = Y;
toc

ref = load('../matlab_reference/reference_data.mat');
piv_error(imageA, imageB, ref.X, ref.Y, ref.U, ref.V, X, Y, U, V);    

end