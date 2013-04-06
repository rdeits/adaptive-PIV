% Parameter-example file 

im1= 'Demo1/im00.bmp'; %The "base" image
im2= 'Demo1/im04.bmp'; %The "cross" image

Dt=0.04; %Time between images

winsize=[64 64;64 64;32 32;32 32]; %interrogation region size

overlap=0.5; % Overlap of interrogation regions

method='multin'; %Method for interrogation (i.e. multiple passes)

wocofile='Demo1/worldco.mat'; %file containting the mapping from image to
                          %world coordinates
			  
msk='Demo1/polymask.mat'; %file defining the regions to mask from the
                          %flow.

