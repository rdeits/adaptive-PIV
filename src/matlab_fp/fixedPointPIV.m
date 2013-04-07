function [X,Y,U,V,edge] = fixedPointPIV(imageA,imageB)

%window size and overlap factor
Ws = 64;
OF = 0.75;

%calculate spacing based on Ws and OF
[Ir,Ic] = size(imageA);
spacing = ceil(Ws-(OF*Ws));

%set vars to hold vectors
X = [];
Y = [];
U = [];
V = [];

nrows = 0;

%loop over image and do cross-correlations, adding to vector vars
Rpos = 1;
Cpos = 1;
while Rpos+Ws-1<=Ir,
    nrows = nrows + 1;
    while Cpos+Ws-1<=Ic,
        %grab the two frames
        frameA = imageA(Rpos:Rpos+Ws-1,Cpos:Cpos+Ws-1);
        frameB = imageB(Rpos:Rpos+Ws-1,Cpos:Cpos+Ws-1);
        
        %do cross-correlation
        % [Vtemp,Utemp] = crossCorrelation_fp(frameA,frameB);
        [Vtemp,Utemp] = crossCorrelation1(frameA,frameB);
        
        %save relevant variables
        Xtemp = Cpos+ceil(Ws/2);
        Ytemp = Rpos+ceil(Ws/2);
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

X = reshape(X, [], nrows)';
Y = reshape(Y, [], nrows)';
U = reshape(U, [], nrows)';
V = reshape(V, [], nrows)';

%set edge var for visualization
edge = ones(size(X)) * Ws;

end