A=imread('/hom/jks/matpiv/Version1.6/Demo3/mpim1b.bmp');
A=double(A);

B=imread('/hom/jks/matpiv/Version1.6/Demo3/mpim1c.bmp');
B=double(B);
tel=1;
subplot(3,1,1)
imagesc(A), hold on, colormap(gray)
subplot(3,1,2), colormap(gray)
subplot(3,1,3), colormap(gray)
for i=1:1:200
stp=[i 940];
M=64; N=64;

a=A(stp(1):stp(1)+N-1,stp(2):stp(2)+M-1);
b=B(stp(1):stp(1)+N-1,stp(2):stp(2)+M-1);

stad1=std(a(:));
stad2=std(b(:));

ma=mean(a(:)); mb=mean(b(:));
a1=a-ma;
b1=b-mb;

R1=xcorrf2(a1,b1)./(N*M*stad1*stad2);
[y1,x1]=find(R1==max(R1(:)));
[x01,y01]=intpeak(x1,y1,R1(y1,x1),R1(y1,x1-1),R1(y1,x1+1),R1(y1-1,x1),R1(y1+1,x1),2,M);

R2=pcorr2(a,b);
[y2,x2]=find(R2==max(R2(:)));
[x02,y02]=intpeak(x2,y2,R2(y2,x2),R2(y2,x2-1),R2(y2,x2+1),R2(y2-1, ...
						  x2),R2(y2+1,x2),2,M/2 +1);
%figure(gcf), clf
%subplot(3,1,1), imagesc(a)
%subplot(3,1,2), imagesc(b)
%subplot(3,1,3), imagesc(R2)
subplot(3,1,1)
if tel~=1, delete(h), end
h=plot([stp(2) stp(2) stp(2)+N-1 stp(2)+N-1 stp(2)],...
       [stp(1) stp(1)+M-1 stp(1)+M-1 stp(1) stp(1)],'k-'); %set(h,'LineWidth',2);

subplot(3,1,2)
imagesc(a)

subplot(3,1,3)
pcolor(R2), caxis([0.1 0.2]), axis tight
%[X,MAP]=capture;
%Mov(tel)=im2frame(X,MAP);
Mov(tel)=getframe;

tel=tel+1;
end
