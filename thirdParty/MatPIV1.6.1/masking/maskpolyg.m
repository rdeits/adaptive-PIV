function [x,y,u,v]=maskpolyg(x,y,u,v,masker)
%function [x,y,u,v]=maskpolyg(x,y,u,v,mask)
% 
% X,Y,U and V are matrices as produced by MATPIV. MASK can be either
% a vector of vertices with [xvertice yvertice], or a string
% specifying the filename for the mask (MASK.M by default saves the
% polygon vertces to a file called polymask.mat, so in most cases
% this should be your string). 
% Set's gridpoints that are inside a mask defined by IX and IY
% equal to NaN.
%
% See also MATPIV, MASK, 
%
% maskpolyg 1.Feb. 2001, by jks
% For use with MatPIV 1.5
  
if ischar(masker)==1
  D=load(masker);
  ix=D.polymask(:,1);
  iy=D.polymask(:,2);
elseif ischar(masker)==0
  ix=masker(:,1);
  iy=masker(:,2);
end
% find all points inside polygon  
in=inpolygon(x,y,ix,iy);

u(in)=NaN;
v(in)=NaN;
  