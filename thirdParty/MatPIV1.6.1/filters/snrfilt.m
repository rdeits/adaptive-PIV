function [U,V]=snrfilt(X,Y,U,V,SnR,trhld,varargin)
  
% function [newu,newv]=snrfilt(X,Y,U,V,SnR,treshold,actions)
%
% Function used to evaluate the vector field. Takes the SnR from MatPIV
% as input along with the velocities U and V, the positions X and Y and
% a threshold level TRHLD. ACTIONS can be omitted but speciying 'loop'
% will allow the user to interactively choose an appropriate threshold
% level. Additionally one can add 'interp' to include interpolation
% of outliers.
%
% See also: MATPIV, GLOBFILT, LOCALFILT, MASK, MASKPOLYG.

% For use with MatPIV 1.6
%
% Copyright 1999-2001 by J.K.Sveen (jks@math.uio.no)
% Dept. of Mathematics, Mechanics Division, University of Oslo, Norway

if nargin==5
  trhld=1.3;
  disp('WARNING....no threshold specified. Using standard setting!')
end

[sy,sx]=size(U);
% set the scale for plotting
scale=3/max(sqrt(U(:).^2 + V(:).^2));

prev=isnan(U); if ~isempty(prev), previndx=find(prev==1);end
usr=1; msknan=sum(prev(:));
while usr~=0,
    fprintf([' SnR filter running with threshold value = ', num2str(trhld)])
    
    [yy]=find(SnR<trhld & ~isnan(U));  
    
    if any(strcmp(varargin,'loop'))
        figure(1), hold off
        vekplot2(X,Y,U,V,scale,'b');
        hold on
        if ~isempty(yy)
            vekplot2(X(yy),Y(yy),U(yy),V(yy),scale,'r');
            rest=length(yy);    
        else  
            rest=0;
        end
        title([' Possible outliers indicated with red arrows. Threshold value is ', ...
                num2str(trhld)]);       
        xlabel([num2str(rest),' outliers identified by this filter, from totally ',...
                num2str(size(U(:),1)),' vectors'])
        usr=input(' To change THRESHOLD type new value, \n type 0 to use current value >> ');
    else
        usr=0;
    end
    
    if ~isempty(yy)   
        % Now we asign NotANumber (NaN) to all the points in the matrix that
        % exceeds our threshold.
        U(yy)=NaN; V(yy)=NaN;
        rest=length(yy);
    else
        rest=0;
    end
    
    disp(['  - finished... ',num2str(rest),' outliers identified'])
    
end

U=reshape(U,sy,sx); V=reshape(V,sy,sx);
