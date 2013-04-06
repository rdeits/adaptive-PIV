function [pilx,pily]=vekplot2(x,y,u,v,scale,line,mark,fillcolor)
% VEKPLOT2 - plot vectors as arrows 
% [pilx,pily]=vekplot2(x,y,u,v,scale,line,mark,fillcolor)
% 
% This function is essentially the same as quiver, but in VEKPLOT2 the 
% scale is known so that plotting two vector-fields on top of each other
% for comparison, is possible.
%
% scale: the length in the figure when u^2 + v^2 = 1
% pilx,pily : matrices formed so that plot(pilx,pily) gives a vectorplot
%
% if MARK is specified as 'fillhead' the arrowheads will be filled using
% the same color as the arrow itself.
%
% See also: QUIVER, QUIVER3, FEATHER, PLOT

% Copyright Per-Olav Rusaas 1997-2001, por@bukharin.hiof.no
%
% Modifications by J. Kristian Sveen, jks@math.uio.no, 23. Jan. 2002

if ischar(x)
    if nargin==3
        line=u;
    elseif nargin==2
        line='b';
    end
    scale=y; 
    y=load(x);
    x=y(:,1); u=y(:,3); v=y(:,4); y=y(:,2);
else
    if  size(x,2)==4
        scale=y; clear y;
        y=x(:,2); u=x(:,3); v=x(:,4); x=x(:,1);     
    end
end

% remove NaN's
% feature added 15-Nov-2001
ii=~isnan(u);
x=x(ii); y=y(ii); u=u(ii); v=v(ii); 
%

x=x(:)'; y=y(:)'; u=u(:)'; v=v(:)';

maksspiss=0.1*scale;  % maks. lengde av spiss-sidene
alfa=pi/16;            % halve vinkelen for spissen

ih=ishold;

x1=x;
x2=x+u*scale;
y1=y;
y2=y+v*scale;
r=sqrt((x2-x1).^2 + (y2-y1).^2);

retcos=[cos(alfa), -sin(alfa) ; sin(alfa), cos(alfa)];

spisslengde=min(0.6*ones(size(r)), 0.4*r);
spisslengde(2,:)=spisslengde(1,:);

lvek1=retcos*[(x1-x2) ; (y1-y2)];
lvek2=retcos'*[(x1-x2) ; (y1-y2)];
lengde=sqrt(lvek1(1,:).^2+lvek1(2,:).^2);
lengde=max(lengde,ones(size(lengde))*1.0e-200);
lengde(2,:)=lengde(1,:);
lvek1=lvek1./lengde .* spisslengde;
lvek2=lvek2./lengde .* spisslengde;

pilx=[x1; x2; x2+lvek1(1,:); x2; x2+lvek2(1,:)];
pily=[y1; y2; y2+lvek1(2,:); y2; y2+lvek2(2,:)];

vecx=[x1; x2; repmat(NaN,size(x1))];
vecy=[y1; y2; repmat(NaN,size(y1))];
px=[x2+lvek1(1,:); x2; x2+lvek2(1,:); repmat(NaN,size(x1))];
py=[y2+lvek1(2,:); y2; y2+lvek2(2,:); repmat(NaN,size(y1))];

if ~exist('line','var')
    line='b';
end

%if nargin<6 
%    plot(vecx(:),vecy(:),'b-')
%    hold on
%    plot(px(:),py(:),'b-')
    %plot(pilx,pily,'blue-')
    %else
    plot(vecx(:),vecy(:),line)
    hold on
    
    %plot(pilx,pily,line)
    %end

if nargin==7 & ~isempty(mark)
    if strcmp(mark,'fillhead')~=1
        hold on
        plot(x,y,line);
    else
        px2=[x2+lvek1(1,:); x2; x2+lvek2(1,:);x2+lvek1(1,:)];
        py2=[y2+lvek1(2,:); y2; y2+lvek2(2,:);y2+lvek1(2,:)];
        % plot the arrowheads
        h=patch(px2,py2,fillcolor);
        set(h,'EdgeColor',get(h,'FaceColor'))
    end
end

% plot the arrowheads
plot(px(:),py(:),line)

if nargin==8 & ~isempty(fillcolor)
    hold on
    ha=plot(x,y,line);
    set(ha,'markerFaceColor',fillcolor)
end

if ih
    hold on
else
    hold off
end

if nargout==0
    clear pilx pily
end


