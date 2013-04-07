function [X,Y,U,V,edgeX,edgeY,edgeSize] = adaptivePIV1(imageA,imageB,Xprev,Yprev,Uprev,Vprev,edgeSizePrev)

%set final grid size
Ws = 64;
OF = 0.75;

%get size of image
[Ir,Ic] = size(imageA);

%set vars to hold vectors
X = [];
Y = [];
U = [];
V = [];
edgeSize = [];

%get 2d PDF for seeding density and window size
seeding = adaptivePIVseeding1(imageA,imageB,edgeSizePrev);
if ~isempty(Xprev),
    vStdDev = adaptivePIVvStdDev1(Xprev,Yprev,Uprev,Vprev,edgeSizePrev);
    vStdDev = imresize(vStdDev,size(seeding));
    vStdDev = vStdDev + 0.25;
    density = seeding .* vStdDev;
else,
    density = seeding;
end

%select interrogation window locations
spacing = Ws * (1-OF);
numFrames = ceil((Ir/spacing)*(Ic/spacing)*(1/4));
[Rs,Cs,values] = adaptivePIVselect1(density,numFrames);

%loop and perform cross-correlations
for i = 1:numFrames,
    %grab relevant frames
    [frameA,frameB] = adaptivePIVgetFrame1(imageA,imageB,Rs(i),Cs(i),values(i));
    
    %perform cross-correlation
    [Vtemp,Utemp] = crossCorrelation1(frameA,frameB);
    
    %save relevant variables
    Xtemp = Cs(i);
    Ytemp = Rs(i);
    edgeSizeTemp = length(frameA);
    X = [X; Xtemp];
    Y = [Y; Ytemp];
    U = [U; Utemp];
    V = [V; Vtemp];
    edgeSize = [edgeSize; edgeSizeTemp];
end

%interpolate into an ordered grid
edgeX = X;
edgeY = Y;
[X,Y,U,V] = makePIVgrid1(Ws,OF,Ir,Ic,X,Y,U,V);

end

function seeding = adaptivePIVseeding1(imageA,imageB,edgeSizePrev)

imageAtemp = uint8(imageA);
bw = mean(mean(imageAtemp))/255 * (3/4);
image = double(im2bw(imageAtemp,bw));

%image = imageA+imageB;

%h = 64;
if isempty(edgeSizePrev),
    h = 64;
else,
    h = ceil(mean(edgeSizePrev));
end

if h<3,
    h = 3;
end
sig = ceil(h/4);
G = fspecial('gaussian',[h,h],sig);
seeding = imfilter(image,G,'same');

end

function vStdDev = adaptivePIVvStdDev1(Xprev,Yprev,Uprev,Vprev,edgeSizePrev)

if isempty(edgeSizePrev),
    h = 128;
else,
    h = ceil(mean(edgeSizePrev));
end

spacing = Xprev(2)-Xprev(1);
nhood = round(h/spacing);
if mod(nhood,2)==0,
    nhood = nhood+1;
end
nhood = ones(nhood);

width = find(Yprev==min(min(Yprev)),1,'last');
Uprev = reshape(Uprev,width,[])';
Vprev = reshape(Vprev,width,[])';

sigU = stdfilt(Uprev,nhood);
sigV = stdfilt(Vprev,nhood);
vStdDev = (sigU.^2 + sigV.^2).^(0.5);

end

function [Rs,Cs,values] = adaptivePIVselect1(density,numFrames)

colSums = cumsum(density);
colSums = colSums(end,:);

Rs = [];
Cs = [];
values = [];

for i = 1:numFrames,
    c = PDFselect(colSums);
    column = density(:,c);
    r = PDFselect(column');
    Rs = [Rs; r];
    Cs = [Cs; c];
    values = [values; density(r,c)];
end

end

function i = PDFselect(vec)

vecSum = cumsum(vec);
p = rand * max(max(vecSum));

i = find(vecSum>=p,1,'first');

end

function [frameA,frameB] = adaptivePIVgetFrame1(imageA,imageB,r,c,value)

[rows,cols] = size(imageA);

minEdge = 25;
maxEdge = 128;

if value>=0.3,
    edge = round(-50 * value + 75);
else,
    edge = round(130 * exp(-2.492 * value));
end

if edge < minEdge,
    edge = minEdge;
end
if edge > maxEdge,
    edge = maxEdge;
end

rMin = ceil(r-(edge/2));
rMax = rMin + edge;
cMin = ceil(c-(edge/2));
cMax = cMin + edge;

if rMin < 1,
    rMin = 1;
end
if rMax > rows,
    rMax = rows;
end

if cMin < 1,
    cMin = 1;
end
if cMax > cols,
    cMax = cols;
end

frameA = imageA(rMin:rMax,cMin:cMax);
frameB = imageB(rMin:rMax,cMin:cMax);

end

function [X,Y,U,V] = makePIVgrid1(Ws,OF,Ir,Ic,Xad,Yad,Uad,Vad)
%set vars to hold vectors
X = [];
Y = [];
U = [];
V = [];

%do Delauney tri 
dt = DelaunayTri(Xad,Yad);

%loop over image and do cross-correlations, adding to vector vars
spacing = ceil(Ws-(OF*Ws));
Rpos = 1;
Cpos = 1;
while Rpos+Ws-1<=Ir,
    while Cpos+Ws-1<=Ic,
        Xtemp = Cpos+ceil(Ws/2);
        Ytemp = Rpos+ceil(Ws/2);
        
        q = [Xtemp,Ytemp];
        pid = nearestNeighbor(dt,q);
        Utemp = Uad(pid(1));
        Vtemp = Vad(pid(1));
        
        X = [X; Xtemp];
        Y = [Y; Ytemp];
        U = [U; Utemp];
        V = [V; Vtemp];
        
        %shift for next iter
        Cpos = Cpos + spacing;
    end
    
    %reset and shift for next iter
    Cpos = 1;
    Rpos = Rpos + spacing;
end

end