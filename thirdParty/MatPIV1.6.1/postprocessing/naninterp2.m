function [u,v]=naninterp2(u,v,mask,xx,yy)
% function [u,v]=naninterp2(u,v,mask,x,y)
%
% Interpolates NaN's in a vectorfield. Used by GLOBFILT,
% MEDIANFILT and VALIDATE. Sorts all spurious vectors based on the
% number of spurous neighbors to a point. Interpolation starts with
% the ones that have the least number of outliers in their
% neighborhood and loops until no NaN's are present in the field.
%


% 1999 - 2001, J. Kristian Sveen (jks@math.uio.no)
% For use with MatPIV 1.6, Copyright
% Distributed under the terms of the GNU - GPL license
% timestamp: 15:46, Oct 23, 2001

% determine Calling m-file:
[stru,II]=dbstack;
if length(stru)>2
    test=stru(3).name;
    I2=findstr(test,'multipass');
    if isempty(I2), I2=0; end
else
    I2=0;
end 
if nargin==2
    [py,px]=find(isnan(u)==1);  
else
    py2=[];px2=[]; ipol2=zeros(size(xx));
    for i=1:size(mask,2)
        if I2~=0
            ipol1=inpolygon(xx,yy,mask(i).idx,mask(i).idy);
            ipol2=ipol2+ipol1;
        else
            ipol1=inpolygon(xx,yy,mask(i).idxw,mask(i).idyw);
            ipol2=ipol2+ipol1;
        end 
    end
    [py,px]=find(isnan(u)==1 & ~ipol2 );     
end

numm=size(py);
[dy,dx]=size(u);
teller=1;
lp=1;
tel=1;
% Now sort the NaN's after how many neighbors they have that are
% physical values. Then we first interpolate those that have 8
% neighbors, followed by 7, 6, 5, 4, 3, 2 and 1
% use SORTROWS to sort the numbers
fprintf(' Interpolating outliers: ')
%pcolor(u), hold on
while ~isempty(py)
    % check number of neighbors
    for i=1:length(py)
        %correction if vector is on edge of matrix
        corx1=0; corx2=0; cory1=0; cory2=0;
        if py(i)==1, cory1=1; cory2=0;
        elseif py(i)==dy, cory1=0; cory2=-1; end
        if px(i)==1, corx1=1; corx2=0;
        elseif px(i)==dx,  corx1=0; corx2=-1; end
        ma = u( py(i)-1+cory1:py(i)+1+cory2, px(i)-1+corx1:px(i)+1+corx2 );
        nei(i,1)=sum(~isnan(ma(:)));
        nei(i,2)=px(i);
        nei(i,3)=py(i);
    end
    % now sort the rows of NEI to interpolate the vectors with the
    % fewest spurious neighbors.
    nei=flipud(sortrows(nei,1));
    % reconstruct the sorted outlier-vectors.
    % and only interpolate the first 50% of vectors
    ind=find(nei(:,1)>=8);
    while isempty(ind)
        ind=find(nei(:,1)>=8-tel);
        tel=tel+1;
    end
    tel=1;
    py=nei(ind,3);
    px=nei(ind,2);
    for j=1:size(py,1)
        corx1=0; corx2=0; cory1=0; cory2=0;
        if py(j)==1
            cory1=1; cory2=0;
        elseif py(j)==dy
            cory1=0; cory2=-1;
        end
        if px(j)==1
            corx1=1; corx2=0;
        elseif px(j)==dx
            corx1=0; corx2=-1;
        end
        tmpu=u(py(j)-1+cory1:py(j)+1+cory2, px(j)-1+corx1:px(j)+1+corx2);
        tmpv=v(py(j)-1+cory1:py(j)+1+cory2, px(j)-1+corx1:px(j)+1+corx2);
        u(py(j),px(j))=mnanmean(tmpu(:));
        v(py(j),px(j))=mnanmean(tmpv(:));
        if lp>numm(1), u(py(j),px(j))=0;v(py(j),px(j))=0;end
        teller=teller+1;
    end 
    tt=length(py);
    
    if nargin==2
        [py,px]=find(isnan(u)==1);  
    else
        %in2=zeros(size(xx));
        %for i=1:length(mask)
        %    in=inpolygon(xx,yy,mask(i).idxw,mask(i).idyw);
        %    in2=in2+double(in);
        %end
        [py,px]=find(isnan(u)==1 & ~ipol2 );
    end
    
    lp=lp+1;
    fprintf('.')
end
if numm(1)~=0
    
    fprintf([num2str(numm(1)),' Nan''s interpolated.\n'])
else
    fprintf('Nothing to interpolate \n')
end 