function [maske,x,y,u,v]=mask(ima,wocofile,x,y,u,v)
%
% function [mask,x,y,u,v]=mask(ima,wocofile,x,y,u,v)
% 
% Uses roipoly to let the user mask a region of his/her image and
% thereby exclude a part of the flow.
% IMA is the first image from your PIV measurements.
% WOCOFILE is the world coordinate file as output by the DEFINEWOCO 
% m-file.
% The mask is output in variable MASK and is of the same size as
% the input image. it is a matrix with 0's where the mask is and
% 1's elsewhere. 
% IDXW and IDYW are the vertices of the polygon given in 
% WorldCoordinates.
% X,Y,U and V are optional as input arguments, but then the
% velocity vectors will have to be masked manually using the IDXW
% and IDYW vectors (which define the polygon) and the file MASKPOLYG.
%
% See also ROIPOLY, MATPIV, DEFINEWOCO, MASKPOLYG

% MASK Beta version Feb 1 2001 for use with MATPIV 1.5
%
% Copyright 2000-2001 J.K. Sveen, jks@math.uio.no
% Mechanics Division, Depth of Mathematics
% University of Oslo, Norway
%
% Distributed under the terms of the GNU General Public License
%
% Timestamp: 22:30, 20 Feb 2001

if ischar(ima)
  [A,p1]=imread(ima);
  if isrgb(A), A=rgb2gray(A); end
  if ~isempty(p1), A=ind2gray(A,p1); end
  
  if nargin==1
      wocofile='';
  end
else
    A=ima;
end
  inp=1;
  tel=1;
  while inp~=0,
      disp('Mark your polygon points with the left mouse button.')
      disp('Press the middle button when you are finished, press')
      disp('<BACKSPACE> or <DELETE> to remove the previously selected vertex.')
  
      [maske(tel).msk,maske(tel).idx,maske(tel).idy]=roipoly(A);  
      hold on
      %in=inpolygon(A,double(idx),double(idy));
      [py,px]=find(maske(tel).msk==1);
      h1=plot(px(1:4:end),py(1:4:end),'.r');
      
      inp=input('Do you whish to add another field to mask? (1 = yes, 0 = no) >> ');
      tel=tel+1;
  end
  clf, imshow(A), hold on
  for i=1:length(maske)
      [py,px]=find(maske(i).msk==1);
      h1=plot(px(1:6:end),py(1:6:end),'.r');
  end

  % Convert masks local pixelcoordinates to World-Coordinates
  D=dir(wocofile);
  if size(D,1)==1
      for i=1:length(maske)
          mapp=load(D(1).name);
          [maske(i).idxw,maske(i).idyw]=pixel2world(double(maske(i).idx),double(maske(i).idy),...
              double(maske(i).idx),double(maske(i).idy),mapp.comap(:,1),mapp.comap(:,2));
      end
  else
    disp('No such world coordinate file present!')
  end
  
  % Set points inside polygon to NaN if velocity field was given in input
  if nargin>2
      for i=1:length(maske)
          [x,y,u,v]=maskpolyg(x,y,u,v,[maske(i).idxw maske(i).idyw]);
      end
  end
  
  % save the polygon to a file
  %for i=1:length(maske)
  %    polymask(i)=[maske(i).idxw(:) maske(i).idyw(:) maske(i).idx(:) maske(i).idy(:)]; 
  %end
  save polymask.mat maske
  
