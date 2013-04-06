function [u,v]=peakfilt(x,y,u,v,pkh,lim,act);

% PEAKFILT - filter PIV data based on the peak height of each correlation peak.
%
% [u,v]=peakfilt(x,y,u,v,pkh,0.3); removes all the vecors where the peak height
% (normalized) is lower than 0.3.
% [u,v]=peakfilt(x,y,u,v,pkh,0.3,'loop'); allows the user to interactively set
% the threshold with the result plotted in a figure.
%
%

% Copyright  2001, J. Kristian Sveen, jks@math.uio.no
% 
% for use with MatPIV 1.6, Distributed under the GNU general public license.

if nargin<6
    disp('Not enough input arguments!'); return
elseif nargin==6
    if ~isnumeric(lim)
        disp('Filter threshold should be numeric'); return
    end
    act='';
end

[sy,sx]=size(u);
prenan=isnan(u(:));

[ii]=find(pkh(:)<lim & ~prenan(:));
fprintf(' Peak height filter running ....')
usr=lim;
if strcmp(act,'loop')==1 
    figure
    fprintf('\n')
    while usr~=0
        lim=usr;
        [ii]=find(pkh<lim & ~prenan);
        sc=10/max(sqrt(u(:).^2 + v(:).^2));
        vekplot2(x,y,u,v,sc,'b');
        hold on
        vekplot2(x(ii),y(ii),u(ii),v(ii),sc,'r');
        xlabel([num2str(length(ii)),' outliers found, using threshold ',...
                num2str(lim)]);
        usr=input('Type new threshold value, (type 0 to use current) >> ');       
    end
end
% set the outliers to NaN.
u(ii)=nan; v(ii)=nan;
fprintf(['... ',num2str(length(ii)),' vectors changed \n'])

% reshape the velocity matrix so that it is equal to the input-matrix.
u=reshape(u,sy,sx); v=reshape(v,sy,sx);