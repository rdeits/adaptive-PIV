%  MatPIV - Particle Image Velocimetry (PIV) Toolbox
%  Version 1.6.1, 
% 
%  Written by J. Kristian Sveen, 1998-2004,
%  J.K.Sveen@damtp.cam.ac.uk, jks@math.uio.no
% 
%   Release information
%     Readme         - New features, bug fixes, and changes in this version.
%
%   PIV - files
%     matpiv         - Core PIV file. All calculations start here.
%                      Call MatPIV using one of the following options: 
%       singlepass   - 'single', PIV with a single pass through images
%       multipass    - 'multi', PIV using 3 iterations 
%       multipassx   - 'multin', PIV using N iterations 
%       mqd          - 'mqd', PIV using minimum quadratic difference, 1 pass
%       normpass     - 'norm', PIV using normalized correlations, 1 pass
%     definewoco     - define transformation between pixels and centimeters
%     mask           - mask out regions of the flow from calculations
%     mask2          - version of MASK that avoids use of the Image Proc. Toolb.
%     snrfilt        - Filter velocities based on Signal to Noise
%                      ratio in correlation plane
%     peakfilt       - Filter velocities based on correlation peak height
%     globfilt       - Filter velocities based on global vector properties
%     localfilt      - Filter velocities based on local vector properties
%     naninterp      - Interpolate NaNs after filtering
%    
%    
%   Visualisation tools
%     vekplot2       - Plot vectors. Same functionality as QUIVER,
%                      but here the scale is known, so two vector
%                      fields can be compared easily
%     magnitude      - plot sqrt(u^2+v^2) as an image
%     mstreamline    - wrapper call to STREAMLINE. Creates starting
%                      points for streamlines based on image edges
%     strain         - Calculate strain in a vector field
%     vorticity      - Calculate vorticity in a vector field
%    
%    
%   Additional files
%     mnanmedian     - Calculate the median value in an array
%                      disregarding NaNs
%     mnanmean       - As above, but mean.
%     mnanstd        - As above, but Standard Deviation.
%     weight         - Create weight-matrix to remove bias errors due
%                      to particles truncated on interrogation region edges.
%     bgconstruct2   - Construct a background image from a number of
%                      PIV images. 
%     automask       - A first attempt to construct an automatic mask
%                      for PIV images
%     mginput        - reworking of original ginput function to
%                      change the pointer type to a circle
%     articross.mat  - Artificial cross needed in DEFINEWOCO
%     articross2.mat - Artificial X needed in DEFINEWOCO
%
%  Example (cd to the MatPIV directory first):
%  [x,y,u,v,snr]=matpiv('Demo3/mpim1b.bmp','Demo3/mpim1c.bmp',...
%  [128 128; 64 64;32 32; 32 32],0.008,0.5,...
%  'multin','Demo3/worldco0.mat','Demo3/polymask.mat');
%  
%  Filtering example:
%  [su,sv]=snrfilt(x,y,u,v,snr,1.3);
%  [gu,gv]=globfilt(x,y,su,sv,3);
%  [lu,lv]=localfilt(x,y,gu,gv,2,'median',5,'Demo3/polymask.mat');
%  [fu,fv]=naninterp(lu,lv,'linear','Demo3/polymask.mat',x,y);
%
%  Visualising the result:
%  scale=0.5/max(sqrt(fu(:).^2 + fv(:).^2));
%  vekplot2(x,y,u,v,scale,'r');
%  hold on
%  vekplot2(x,y,fu,fv,scale,'g');
%  legend('raw velocity data','','filtered velocity data');