function PIVscaffold1(directory,PIVtype)

%make list of all images in directory
dirPath = ['../data/', directory, '/'];
allImages = [dir([dirPath,'*.png']); 
    dir([dirPath,'*.tif']); 
    dir([dirPath,'*.jpg']); 
    dir([dirPath,'*.bmp'])];

%set a few placeholders
X = [];
Y = [];
U = [];
V = [];
edgeSize = [];

for i = 1:floor(length(allImages)/2),
    
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
    if strcmp(PIVtype,'normal'),
        %window size and overlap factor
        Ws = 64;
        OF = 0.75;
        [X,Y,U,V,edgeSize] = normalPIV1(imageA,imageB, Ws, OF);
        edgeX = X;
        edgeY = Y;
    elseif strcmp(PIVtype,'adaptive'),
        [X,Y,U,V,edgeX,edgeY,edgeSize] = adaptivePIV1(imageA,imageB,X,Y,U,V,edgeSize);
    end
    toc
    
    %display final image
    figure(i)
    imshow(uint8(imageA/2));
    hold on;
    imshow(uint8(imageB/2));
    quiver(X,Y,U,V,'Color','yellow');
    
    %draw edges
    drawFactor = 0.3;
    for j = 1:length(edgeX),
        if rand(1)<drawFactor,
            rectangle('Position',[edgeX(j)-floor(edgeSize(j)/2),edgeY(j)-floor(edgeSize(j)/2),edgeSize(j),edgeSize(j)],'EdgeColor','red');
        end
    end
    hold off;
    
    pause(0.1);
    
end

end