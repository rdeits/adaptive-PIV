function [u]=naninterp1(u,msk)
% function [u]=naninterp1(u,mask)
%
% Interpolates NaN's in a vectorfield. Sorts all NaN's based on the
% number of neighboring "true" values. Interpolation starts with the
% ones that have the least number of NaN's in their neighborhood and
% loops until no NaN's are present in the field.
%
% MSK should be same size as U with ones where there should be NO
% interpolation.
% 
% alpha ver.1, Oct. 1 2000 jks
% For use with MatPIV v1.5

if nargin==2
  
end  
[py,px]=find(isnan(u)==1);
numm=size(py); [dy,dx]=size(u);
tel=1; teller=0;

% Now sort the NaN's after how many neighbors they have that are
% physical values. Then we first interpolate those that have 8
% neighbors, followed by 7, 6, 5, 4, 3, 2 and 1. The number of
% neighbors is updated along the way.

while ~isempty(py)
  % check number of neighbors
  for i=1:length(py)
    %correction if vector is on edge of matrix
    corx1=0; corx2=0; cory1=0; cory2=0;
    if py(i)==1, cory1=1; cory2=0;
    elseif py(i)==dy, cory1=0; cory2=-1; end
    if px(i)==1, corx1=1; corx2=0;
    elseif px(i)==dx, corx1=0; corx2=-1; end
      
    ma = u( py(i)-1+cory1:py(i)+1+cory2,...
	    px(i)-1+corx1:px(i)+1+corx2 );
    nei(i,1)=sum(~isnan(ma(:)));
    nei(i,2)=px(i); nei(i,3)=py(i);
  end
  % now sort the rows of NEI to interpolate the vectors with the
  % fewest spurious neighbors.
  nei=flipud(sortrows(nei,1));

  %locate only the NaNs with the most "true" neighbors
  ind=find(nei(:,1)>=8); 
  while isempty(ind)
    ind=find(nei(:,1)>=8-tel); tel=tel+1;
  end
  % only interpolate these few vectors first.
  tel=1; py2=nei(ind,3); px2=nei(ind,2);

  % main interpolation loop
  for j=1:size(py2,1)
    corx1=0; corx2=0; cory1=0; cory2=0;
    if py2(j)==1
      cory1=1; cory2=0;
    elseif py2(j)==dy
      cory1=0; cory2=-1;
    end
    if px2(j)==1
      corx1=1; corx2=0;
    elseif px2(j)==dx
      corx1=0; corx2=-1;
    end
    u(py2(j),px2(j))=mnanmean(mnanmean(u(py2(j)-1+cory1:py2(j)+1+cory2,...
				     px2(j)-1+corx1:px2(j)+1+corx2)));
    teller=teller+1;
  end 
  [py,px]=find(isnan(u)==1);
  nei=[];
end

%disp([num2str(numm(1)),' Nan''s interpolated.'])
%disp(num2str(teller))