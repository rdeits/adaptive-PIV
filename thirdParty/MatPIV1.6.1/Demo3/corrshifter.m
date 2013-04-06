% create image shifting figure for LOV conference

a=double(imread('mpim1b.bmp'));
b=double(imread('mpim1c.bmp'));

A=a(250:313,600:663);     
B=b(250:313,600:663);

A=A(16:47,16:47); B=B(16:47,16:47);


figure
pos=get(gcf,'Position')
set(gcf,'Position',[pos(1:2) 400 270])

C=A-mean2(A);
D=B-mean2(B);
R=xcorrf2(C,D)/(32*32*std2(A)*std2(B));

subplot(1,2,1)

tmp=ones(size(A)*3 - 2);
tmp(32:63,32:63)=A+1;
axis off, colormap(gray)
stad1=std2(A); stad2=std2(B);
tel=1;
subplot(1,2,2)
hold on

MakeQTMovie start film.mov
MakeQTMovie framerate 100
MakeQTMovie('size',[400 270])
for j=1:97
    for i=1:97
        tmp2=tmp;
        tmp2(j:32+j-1,i:32+i-1)=B.*tmp(j:32+j-1,i:32+i-1);
        tmp2(tmp2>255)=tmp2(tmp2>255)/200;
        subplot(1,2,1)
        %imshow(tmp2/255,'notruesize')
        imagesc(tmp2)
        caxis([50 300])
        axis off
        drawnow
        subplot(1,2,2)
        imagesc([i:i+1],[j:j+1],R(j:j+1,i:i+1))
        caxis([0 0.5])
        axis([0.5 128.5 0.5 128.5])
        axis off
        drawnow
        MakeQTMovie addplot
        %[X,MAP]=capture;
        %M(tel)=im2frame(X,MAP);
        tel=tel+1;
    end
end
MakeQTMovie finish
MakeQTMovie cleanup
%save movie.mat M
