function [x,y,u,v]=pixel2world(upix,vpix,xpix,ypix,lswo1,lswo2,mapping)

% function [x,y,u,v]=pixel2world(upix,vpix,xpix,ypix,lswo1,lswo2,mapping)
%
% Calculates the pixels to world coordinate transformation
% You need first to use the m-file DEFINEWOCO to specify your
% world coordinate system. Definewoco then calculates 6 numbers
% that are saved to file ( size(lswo1)=size(lswo2)=[3 1] )
% MAPPING is the mapping function from pixel to world coordinates
% and should be 'linear' or 'nonlinear'. The latter uses a second
% degree polynomial.

% 1998 - 2003 , jks@math.uio.no
% For use with MatPIV 1.6 and subsequent versions
%
% Copyright J.K.Sveen (jks@math.uio.no)
% Dept. of Mathematics, Mechanics Division, University of Oslo, Norway
% Distributed under the terms of the Gnu General Public License

if nargin<7
  if ischar(lswo1)
    l=load(lswo1);
    if ~ischar(lswo2)
      disp('Something wrong with your input')
    end
    mapping=lswo2;
    lswo1=l.comap(:,1);
    lswo2=l.comap(:,2);
  else
    mapping='linear';
  end
end


if strcmp(mapping,'linear')==1
  lswo1(4:6)=0; lswo2(4:6)=0;
elseif strcmp(mapping,'nonlinear')==1
  if length(lswo1)<4 | lswo(3)>lswo(1)
    disp('This mapping file is obsolete. As of Version 1.4 of MatPIV the')
    disp('DEFINEWOCO.M has been changed.')
    disp('You need to redefine your world coordinate points using DEFINEWOCO.M')
    %disp('Continuing with LINEAR MAPPING............')
    return
    %mapping='linear';
  end
elseif strcmp(mapping,'nonlinear')==0 & strcmp(mapping,'linear')==0
  disp('No such mapping available, try `linear` or `nonlinear`!')
  return
end
fprintf(['* Calculating the pixel to world transformation using ',mapping,' mapping'])
for ii=1:1:size(upix,2)
  for jj=1:1:size(upix,1)
    u(jj,ii)=(lswo1(2)*upix(jj,ii)) + (lswo1(3)*vpix(jj,ii));
    v(jj,ii)=(lswo2(2)*upix(jj,ii)) + (lswo2(3)*vpix(jj,ii));
    x(jj,ii)=lswo1(1)+ lswo1(2)*xpix(jj,ii)+ lswo1(3)*ypix(jj,ii)+...
	  lswo1(4)*(xpix(jj,ii).*ypix(jj,ii))+...
	  lswo1(5)*(xpix(jj,ii).^2)+lswo1(6)*(ypix(jj,ii).^2);
    y(jj,ii)=lswo2(1)+ lswo2(2)*xpix(jj,ii)+ lswo2(3)*ypix(jj,ii)+...
	  lswo2(4)*(xpix(jj,ii).*ypix(jj,ii))+...
	  lswo2(5)*(xpix(jj,ii).^2)+lswo2(6)*(ypix(jj,ii).^2);
  end
end

fprintf(' - DONE\n')
