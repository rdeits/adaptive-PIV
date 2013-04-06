function [outvec]=runfile(varargin)

% [outvec]=runfile('basename')
%
% This file is meant as an introduction to the scripting
% possibillities in MATLAB.
% 
% This specific file assumes that we have a directory containing a
% measurement serie consisting of several images. We assume that the
% images are stored on format: basenameXXXb.bmp and basenameXXXc.bmp, 
% where the 'b' and 'c' means 'base' and 'cross' and XXX is a number
% from 000 to 999. Time separation between base and cross images is
% assumed to be 0.012 seconds. Images are interrogated with 32*32
% pixels large windows, using window shifting. 
% After all velocities have been found these are filterd using
% snrfilt, globfilt and localfilt. Settings have been chosen that
% usually will produce reasonable results.
% Results are saved to disk in two files: Velocities.mat and
% Filtered_Velocities.mat, IF no output is psecified when the
% function is called.
%
% Edit this file to change all the settings.
%
if ~isempty(varargin)
  basename=varargin(1);
else
  disp('Please give the base of the filenames you wish to process!')
  return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings 
T=0.012; % Time separation between base and cross images.
met='multi'; % Use interrogation window offset
woco='worldco1.mat'; % World coordinate file. This may be changed
                     % within the loop as well, e.g. in the cases 
                     % where there are two cameraes
med='median'; % Use median filtering in localfilt
int='interp'; % interpolate outliers
snrtrld=1.2;  % threshold for use with snr-filtering
globtrld=3;   % threshold for use with globalfiltering
loctrld=1.7;  % threshold for use with local filtering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
files=dir([basename,'*.bmp']); 
names={};
[names{1:length(files),1}] = deal(files.name);
names=sortrows(char(names{:}));
numoffiles = max(str2num(names(:,end-7:end-5)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		     
% Main loop
for i=1:numoffiles+1
  if i<10
    imnum=['00',num2str(i-1)]; % remember that images start
  elseif i<100 & i>=10         % to count from 000 not 001
    imnum=['0',num2str(i-1)];
  elseif i<1000 & i>=100
    imnum=num2str(i);
  end
  im1=['ima',num2str(imnum),'b.bmp'];
  im2=['ima',num2str(imnum),'c.bmp'];
  eval(['[x',num2str(i),'y',num2str(i),'u',num2str(i),...
	'v',num2str(i),'snr',num2str(i),...
	']=matpiv(im1,im2,64,T,0.5,met,woco);'])
end	
if nargout==0
  save Velocities.mat
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filtering
for i=1:numoffiles
% SnR filter:
  eval(['[su',num2str(i),'sv',num2str(i),...
	']=snrfilt(x',num2str(i),'y',num2str(i),'u',num2str(i),...
	'v',num2str(i),'snr',num2str(i),'snrtrld,int);'])
% global filter:
  eval(['[gu',num2str(i),'gv',num2str(i),...
	']=globfilt(x',num2str(i),'y',num2str(i),'su',num2str(i),...
	'sv',num2str(i),',globtrld,int);'])
% local median filter:
  eval(['[fu',num2str(i),'fv',num2str(i),...
	']=localfilt(x',num2str(i),'y',num2str(i),'gu',num2str(i),...
	'gv',num2str(i),'loctrld,med,int);'])
  outvec{i}.x=eval(['[x',num2str(i),'];'])
  outvec{i}.y=eval(['[y',num2str(i),'];'])
  outvec{i}.u=eval(['[u',num2str(i),'];'])
  outvec{i}.v=eval(['[v',num2str(i),'];'])
  outvec{i}.snr=eval(['[snr',num2str(i),'];'])
  outvec{i}.fu=eval(['[fu',num2str(i),'];'])
  outvec{i}.fv=eval(['[fv',num2str(i),'];'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If runfile was called without output arguments we save the results
% to file. Else the variable outvec contains the original velocity
% measurements plus the final filtered velocities.
if nargout==0
  clear outvec %no point in saving two copies of every measurement.
  save Filtered_Velocities.mat
end
