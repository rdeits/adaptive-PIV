function [xo,yo,uo,vo]=fixdigim(x,y,u,v,interp,sx,sy)

% FIXDIGIM creates matrices out of DigImage vectors
% [x,y,u,v]=fixdigim(x,y,u,v,interpolate,sx,sy)
% 
% Interpolate should be specified as 'interp'
% SX and SY are optional inputs to be used when the matrices X and Y
% cannot be constructed from the input vectors. SX and SY should be
% the true vectors with all elements present.
%
% Alternatively one can specify a file as input. The file need to be
% in ascii format and will be loaded automatically.
% [x,y,u,v]=fixdigim('file.txt','interp',sx,sy);
% will load the file, create matrices of sx*sy size and finally
% interpolate NaN's
%
  
  if nargin==1
    if ischar(x)
      a=load(x,'ascii');
      x=a(:,1); y=a(:,2); u=a(:,3); v=a(:,4);
    else
      x1=x(:,1);      y=x(:,2);
      u=x(:,3);      v=x(:,4);
      clear x,
      x=x1;
    end
  elseif nargin==2  
     if ischar(x)
      a=load(x,'ascii');
      x=a(:,1); y=a(:,2); u=a(:,3); v=a(:,4);
    else
      x1=x(:,1);      y=x(:,2);
      u=x(:,3);      v=x(:,4);
      clear x,
      x=x1;
    end
  end
  
  xx=unique(x);
  yy=unique(y);
  
  if nargin>5
    xx=sx;
    yy=sy;
  end
  
  disp(['Using a ',num2str(length(xx)),' x ',num2str(length(yy)),' grid']);
  
  xo=(xx*ones(1,length(unique(yy)))).';
  yo=yy*ones(1,length(unique(xx)));
  
  teller=1;nantel=0;super=1;
  for i=1:length(xx)
    for j=1:length(yy)
      %[teller length(y(:))]
      if teller<length(x(:))
	if xo(j,i)==x(teller) & yo(j,i)==y(teller)
	  uo(j,i)=u(teller);
	  vo(j,i)=v(teller);
	  teller=teller+1;
	else 
	  uo(j,i)=NaN;
	  vo(j,i)=NaN;
	  nantel=nantel+1;
	end  
	super=super+1;
      end
    end
  end
  disp([num2str(nantel),' Nan''s in the field. '])
%%%%%%%%%%%%%%%%Interpolate
if nargin>4
  if strcmp(interp,'interp')
    [uo,vo]=naninterp(uo,vo);
  else
    disp('No interpolation. Check your input.')
  end
end

if nargin==2 &  strcmp(y,'interp') 
  [uo,vo]=naninterp(uo,vo);
end