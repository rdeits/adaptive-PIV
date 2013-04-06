realx=3; realy=4;
a=double(imread('mpim1b.bmp'));
b=double(imread('mpim1c.bmp'));

A=(a(230:293,720:783));
B=(a(230+realy:293+realy,720+realx:783+realx));

% now create artificial background gradient

tmp=zeros(size(A));
for i=1:64
  for j=1:64
    itmp(j,i)=i/4;
  end
end


R=xcorrf2(A-mean(A(:)),B-mean(B(:)));
[y1,x1]=find(R==max(R(:)));
% this is the default PIV measurement for these images
% NOTE  NO WINDOW SHIFTING
[xr,yr]=intpeak(x1,y1,R(y1,x1),R(y1,x1-1),R(y1,x1+1), ...
		R(y1-1,x1),R(y1+1,x1),2,64);

Rn=nxcorr2(A-mean(A(:)),B-mean(B(:)));
Rn=flipud(fliplr(Rn));
[y1,x1]=find(Rn==max(Rn(:)));
% this is the default PIV measurement for these images
% NOTE  NO WINDOW SHIFTING
[xrn,yrn]=intpeak(x1,y1,Rn(y1,x1),Rn(y1,x1-1),Rn(y1,x1+1), ...
		Rn(y1-1,x1),Rn(y1+1,x1),2,64);

am=max(A(:)); bm=max(B(:));
%tmp=tmp*2;
for jj=1:9
  if jj~=1
    A=(A+flipud(itmp')); A=am.*A./max(A(:));
    B=(B+flipud(itmp')); B=bm.*B./max(B(:));
  end
tel=1; M=64; N=64; winsize=64;

Rn=nxcorr2(A-mean(A(:)),B-mean(B(:)));
Rn=flipud(fliplr(Rn));
[y1,x1]=find(Rn==max(Rn(:)));
% this is the default PIV measurement for these images
% NOTE  NO WINDOW SHIFTING
[xrnm,yrnm]=intpeak(x1,y1,Rn(y1,x1),Rn(y1,x1-1),Rn(y1,x1+1), ...
		Rn(y1-1,x1),Rn(y1+1,x1),2,64);
R2=Rn; R2(y1-5:y1+5,x1-5:x1+5)=NaN;
[p2_y2,p2_x2]=find(R2==max(R2(:)));
normsnr(jj)=Rn(y1,x1)/R2(p2_y2,p2_x2);

for i=0:0.005:1
  r=pcorr2(A-mean(A(:)),B-mean(B(:)),'pad',i,'orig');
   
  [y1,x1]=find(r==max(r(:)));
  if size(x1,1)>1 | size(y1,1)>1
    x1=round(sum(x1.*([1:length(x1)]'))./sum(x1));
    y1=round(sum(y1.*([1:length(y1)]'))./sum(y1));
  end
  
  if x1~=1 & y1~=1 & y1~=N & x1~=M
    tmp=r(y1-1:y1+1,x1-1:x1+1);
    
    [yt1 xt1]=find(tmp==max(tmp([4 6])));
    [yt2 xt2]=find(tmp==max(tmp([2 8])));
    xt1=xt1-2; yt1=yt1-2;
    xt2=xt2-2; yt2=yt2-2;
    
    if length(yt1)==1 & length(yt2)==1
      yt=[yt1 yt2]; yt=yt(yt~=0);
      y01=r(x1,y1+yt)/(r(x1,y1+yt)+r(x1,y1));
      y02=r(x1,y1+yt)/(r(x1,y1+yt)-r(x1,y1)); 
    else 
      yt=0; y01=1;y02=1; %y01 and y02 are dummy values
    end
    if length(xt1)==1 & length(xt2)==1
      xt=[xt1 xt2]; xt=xt(xt~=0);
      x01=r(x1+xt,y1)/(r(x1+xt,y1)+r(x1,y1));
      x02=r(x1+xt,y1)/(r(x1+xt,y1)-r(x1,y1));
    else 
      xt=0;x01=1;x02=1;
    end
    
    x(1,tel)=x1+xt*min(abs([x01 x02]))-M/2 -1;
    y(1,tel)=y1+yt*min(abs([y01 y02]))-N/2 -1;
   
  else
    x(1,tel)=nan;     y(1,tel)=nan;
  end
  
  % Gaussian fit
  [y1,x1]=find(r==max(r(:)));
  [xx,yy]=intpeak(x1,y1,r(y1,x1),r(y1,x1-1),r(y1,x1+1), ...
		  r(y1-1,x1),r(y1+1,x1),1,64/2 +1);
  x(2,tel)=xx;
  y(2,tel)=yy;
  [xx,yy]=intpeak(x1,y1,r(y1,x1),r(y1,x1-1),r(y1,x1+1), ...
		  r(y1-1,x1),r(y1+1,x1),2,64/2 +1);
  
  x(3,tel)=xx;
  y(3,tel)=yy;
  [xx,yy]=intpeak(x1,y1,r(y1,x1),r(y1,x1-1),r(y1,x1+1), ...
		  r(y1-1,x1),r(y1+1,x1),3,64/2 +1);

  x(4,tel)=xx;
  y(4,tel)=yy;
  
%  if i==0.5
    R2=r; R2(y1-4:y1+4,x1-4:x1+4)=NaN;
    [p2_y2,p2_x2]=find(R2==max(R2(:)));
    phasesnr(jj,tel)=r(y1,x1)/R2(p2_y2,p2_x2);
 % end
  %imagesc(r)
  %axis([60 100 55 80])
  %title(num2str(i))
  %drawnow
  tel=tel+1;
end

% figure,
% imagesc(R)
% colormap(gray)
% hold on
% plot(x(1,:)+32,y(1,:)+32,'r.-');
% hold on
% plot(x(2,:)+32,y(2,:)+32,'b.-');
% plot(x(3,:)+32,y(3,:)+32,'g.-');
% plot(x(4,:)+32,y(4,:)+32,'k.-');
% plot(xr+64,yr+64,'y*');
% plot(realx+64,realy+64,'c*');
% plot(xrn+64,yrn+64,'ks');

% legend('Sinc','centroid','Gaussian','parabolic','FFTcorr+gaussian','True pos','Normxcorr2')

 x=x-32; y=y-32;
% figure
% plot([0:0.005:1],sqrt(x(1,:).^2 + y(1,:).^2),'r.-')
% hold on
% plot([0:0.005:1],sqrt(x(2,:).^2 + y(2,:).^2),'b.-')
% plot([0:0.005:1],sqrt(x(3,:).^2 + y(3,:).^2),'g.-')
% plot([0:0.005:1],sqrt(x(4,:).^2 + y(4,:).^2),'k.-')
% h1=plot([0 1],[sqrt((xr)^2 + (yr)^2) sqrt((xr)^2 + (yr)^2)],'y*-'); 
% %set(h1,'LineWidth',3)
% h1=plot([0 1],[sqrt((realx)^2 + (realy)^2) sqrt((realx)^2 + (realy)^2)],'c*-'); 
% %set(h1,'LineWidth',3)
% h1=plot([0 1],[sqrt((xrn)^2 + (yrn)^2) sqrt((xrn)^2 + (yrn)^2)],'ks-'); 
% %set(h1,'LineWidth',3)
% legend('Sinc','centroid','Gaussian','parabolic','FFTcorr+gaussian','True pos','Normxcorr2')

 err=(sqrt(x.^2 + y.^2)-sqrt(realx.^2 + realy.^2) );
figure(1)
subplot(3,3,jj)
plot([0:0.005:1],err(1,:),'r.-')
hold on
plot([0:0.005:1],err(2,:),'b.-')
plot([0:0.005:1],err(3,:),'g.-')
plot([0:0.005:1],err(4,:),'k.-')
h1=plot([0 1],...
	[(sqrt((xr)^2 + (yr)^2)-sqrt(realx.^2 + realy.^2)) ...
	 (sqrt((xr)^2 + (yr)^2)-sqrt(realx.^2 + realy.^2))],'y*-'); 
h1=plot([0 1],[0 0],'c*-'); 
h1=plot([0 1],...
	[(sqrt((xrnm)^2 + (yrnm)^2)-sqrt(realx.^2 + realy.^2)) ...
	 (sqrt((xrnm)^2 + (yrnm)^2)-sqrt(realx.^2 + realy.^2))],'ks-'); 
axis([0 1 -0.1 0.05])
%legend('Sinc','centroid','Gaussian','parabolic','FFTcorr+gaussian','True pos','Normxcorr2')
%title(['jj = ',num2str(jj)])

figure(2)
subplot(3,3,jj)
imagesc(A)
end


figure
%plot([1:9],normsnr,'r.-')
%hold
%plot([1:9],phasesnr,'b.-')
surf([0:0.005:1],[1:9]',phasesnr)
hold on
shading interp
%colormap(copper)
surf([0:0.005:1],[1:9]',repmat(normsnr(:),1,size(phasesnr,2)))

%legend('Normxcorr2 SNR','Phasecorr SNR')
xlabel('Increasing background gradient')
zlabel('Signal to Noise ratio')