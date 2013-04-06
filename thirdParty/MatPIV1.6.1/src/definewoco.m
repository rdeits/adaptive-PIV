function [comap,A1,world]=definewoco(filename,typ)
% DEFINEWOCO - calculate the mapping from image to physical coordinates in MatPIV
%
% [comap,A1,world]=definewoco(image,coordinatestyle)
% 
% DEFINEWOCO is a file for calculating the pixel to world 
% coordinate transformation. 
% This function needs an image with distinct coordinate points. 
% These points should either be easily locatable dots in the 
% image (these are assumed to be circular), or they will have to
% be defined by a grid with known spacing. Your points need to be
% WHITE on a BLACK (dark) background.
%
% definewoco('woco.bmp','o'); will assume circular points with a well 
% defined peak
%
% definewoco('woco.bmp','+'); will assume that the image contains a grid 
% with known spacing. In this case the image is cross-correlated with an 
% artificial cross.
%
% definewoco('woco.bmp','x'); will assume that the image contains grid 
% points in the form of x's. In this case the image is cross-correlated 
% with an artificial x (rotated cross).
%
% definewoco('woco.bmp','.'); will assume circular points where the peak 
% is not well defined, for example if it is flat and relatively large. In 
% this case the input-image is cross correlated with a gaussian bell to 
% emphasize the center of each point in the original image. This option has 
% now the added functionality of letting the user enter an aproximate size
% of his/her world-coordinate point. This helps in many cases where the 
% points are "very" wide, for example 20 pixels in diameter.
%
% The user will then have to mark the local regions around each 
% coordinate point using the mouse (first button).
%
% Subsequently the user will be asked to enter the physical coordinates
% (cm) for each point.
%
% In the final step one will have to choose between a linear and non-
% linear mapping function to use in the calculation of the mapping 
% factors. In most cases a linear function will do a proper job.
%
% The final result will be saved to a file in the present work directory. 
% The file is named 'worldcoX.mat', where the X is any number specified 
% by the user. This option is for the cases where one might have two or 
% more different coordinate systems in the same working directory. If this 
% is not the case just press <enter> when asked for a number. The file will 
% then be named 'worldco.mat'
%
% See also: MATPIV


% Copyright, J. Kristian Sveen, 1999-2004, last revision April 16, 2004
%             jks@math.uio.no
% For use with MatPIV 1.6.1
% Distributed under the GNU general public license
format long

if ischar(filename)
  A=imread(filename);
else
  A=filename;
end
if isrgb(A), A=double(rgb2gray(A)); else, A=double(A); end
[ay,ax]=size(A);

my_ver=version;
my_ver=str2num(my_ver(1:3));
if my_ver>=6.5, pixval on, end

if strcmp(typ,'+')==1
  load articross.mat
  disp('....calculating....this may take a few seconds.')
  b=A./max(A(:)); % normalize in order to make max(A(:))=1 (since max(kr(:))=1);
  A=xcorrf2(b-mean(b(:)),kr-mean(kr(:)))./(std(kr(:))*std(b(:))*size(kr,1)*ay);
  [ax,ay]=size(A); [bx,by]=size(b);
  dx=(ax-bx+1)/2; dy=(ay-by+1)/2;
  A=A(dy+1:end-(dy-1),dx+1:end-(dx-1));
  disp('...Done!')
  disp('Now mark the crosses you whish to use as coordinate points')
elseif strcmp(typ,'x')==1
  load articross2.mat
  kr=double(kr);
  disp('....calculating....this may take a few seconds.')
  b=A./max(A(:)); % normalize in order to make max(A(:))=1 (since max(kr(:))=1);
  A=xcorrf2(b-mean(b(:)),kr-mean(kr(:)))./(std(kr(:))*std(b(:))*size(kr,1)*ay);
  [ax,ay]=size(A); [bx,by]=size(b);
  dx=(ax-bx+1)/2; dy=(ay-by+1)/2;
  A=A(dy+1:end-(dy-1),dx+1:end-(dx-1));
  disp('...Done!')
  disp('Now mark the crosses you whish to use as coordinate points')
elseif strcmp(typ,'o')==1
  %no need to do anything with the image in this case
elseif strcmp(typ,'.')==1
  disp('Please give the approximate width of your points (in pixels -')
  point_size=input(['default is 20). Type 0 here to get old behaviour of definewoco: ']);
  if isempty(point_size), point_size=30; 
  else, point_size=point_size+10; end
  w=weight('gaussian',point_size,0.1);
  disp('....calculating....this may take a few seconds.')
  b=A./max(A(:)); % normalize in order to make max(A(:))=1 (since max(w(:))=1);
  A=xcorrf2(b-mean(b(:)),w-mean(w(:)))./...
    (std(b(:))*std(w(:))*(point_size+10)*ay);
  A=A(point_size/2 +1:end-(point_size/2 -1),...
      point_size/2 +1:end-(point_size/2 -1));
  disp('...Done!')
  disp('Now mark the dots you whish to use as coordinate points')
else
  disp('Not a valid coordinate style. Please use either a + or an o')
  return
end
figure
imagesc(A)
usr1=1;

disp('Please mark your world coordinate points with left mouse button.');
disp('Press ENTER when finished!')

[x1,y1]=mginput;
x1=round(x1); y1=round(y1);
for i=1:1:size(x1,1)
    if y1(i)-9<1, edgy1=(y1(i)-9)-1; else edgy1=0; end
    if y1(i)+8>size(A,1), edgy2=(y1(i)+8)-size(A,1); else edgy2=0; end
    
    if x1(i)-9<1, edgx1=(x1(i)-9)-1; else edgx1=0;  end
    if x1(i)+8>size(A,2), edgx2=(x1(i)+8)-size(A,2); else edgx2=0; end
    
    B=A( y1(i)-9+edgy1:y1(i)+8+edgy2, x1(i)-9+edgx1:x1(i)+8+edgx2);
    %figure(2), imagesc(B)
    [max_y1 max_x1]=find(B==max(max(B)));
    if size(max_x1,1)>1 
        max_x1=max_x1(2);   max_y1=max_y1(2);
    end  
    [x0 y0]=intpeak(max_x1,max_y1,B(max_y1,max_x1),...
        B(max_y1,max_x1-1),B(max_y1,max_x1+1),...
        B(max_y1-1,max_x1),B(max_y1+1,max_x1),1,9);
    x(i)=x1(i)+x0;
    y(i)=y1(i)+y0;
end
%close(2)
disp('Now you need to give the physical coordinates to each of the points specified!')
disp('-----------------------')
hold on
for i=1:1:size(x,2)
  hs=plot(x(i),y(i),'wo');
  set(hs,'MarkerSize',[16])
  [world(i,1:2)]=input(['Please enter the world coordinates for the white \n circle  marked in the current figure (in square parenthesis): ']);
  set(hs,'MarkerFaceColor',[0.1 0.1 0.1])
end
% Construct function for fitting.
inpx='inne';
while strcmp(inpx,'inne')
  mapfun=input('Mapping function. (N)onlinear or (L)inear (N/n/L/l): ','s');
  if strcmp(mapfun,'N')==1 | strcmp(mapfun,'n')==1
    if length(world)>=6
      A1=[ones(size(x,2),1) x.' y.' (x.*y).' (x.^2).' (y.^2).'];
      inpx='ute';
    else
      disp('Not enough points specified to calculate nonlinear mapping factors.')
      disp('Using linear mapping function.');
      A1=[ones(size(x,2),1) x.' y.']; 
      inpx='ute';
    end
  elseif strcmp(mapfun,'L')==1 | strcmp(mapfun,'l')==1
    A1=[ones(size(x,2),1) x.' y.'];
    inpx='ute';
  else
    disp('Please specify mapping function! (N/n/L/l)')
  end
end

comap=(A1\world(:,:));  % Fit using a minimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test for error
err=norm( (A1*comap-world));
disp(['Error (norm) = ',num2str(err)])
% give a warning if error is larger than a certain threshold
% 1 is just chosen as a test case. This needs testing.
if err>1
  disp(['WARNING! The minimized system of equations has a large ', ...
	'error.'])
  disp('Consider checking your world coordinate input')
  if strcmp(mapfun,'L') | strcmp(mapfun,'l')
    disp('Also consider using a nonlinear mapping function');
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inp=input('Save coordinate file....specify number >> ');
navn=['worldco',num2str(inp)];
save(navn,'comap')
disp(['Coordinate mapping factors saved to file:  ', navn])

close %close window containing the image

