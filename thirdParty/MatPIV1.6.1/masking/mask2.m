function [maske,x,y,u,v]=mask2(ima,wocofile,x,y,u,v)
% MASK2 - Create a mask 
%
% function [mask,x,y,u,v]=mask2(ima,wocofile,x,y,u,v)
% 
% This function is a rewrite of the original MASK.M file intended for
% users who do not have the Image Processing toolbox available.
%
% let the user mask a region of his/her image and
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

% MASK Beta version Feb 1 2001 
% for use with MATPIV 1.6
%
% Copyright 2000-2001 J.K. Sveen, jks@math.uio.no
% Mechanics Division, Depth of Mathematics
% University of Oslo, Norway
%
% Distributed under the terms of the GNU General Public License
%
% Timestamp: 10:59, 17 Jan 2002

  A=imread(ima);
  [sx,sy]=size(A);
  Ax=repmat([1:size(A,2)],size(A,1),1);
  Ay=repmat([1:size(A,1)]',1,size(A,2));
  inp=1;
  tel=1;
  imshow(A)
  hold on
  while inp==1,
      disp('Mark your polygon points with the left mouse button.')
      disp('Press the <ENTER> when you are finished')
      [maske(tel).idx,maske(tel).idy,inp]=ginput;
      h1=plot([maske(tel).idx; maske(tel).idx(1)],...
          [maske(tel).idy; maske(tel).idy(1)],'r-o') ;
      set(h1,'LineWidth',[2]);
      maske(tel).msk=inpolygon(Ax,Ay,double(maske(tel).idx),double(maske(tel).idy));
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
  