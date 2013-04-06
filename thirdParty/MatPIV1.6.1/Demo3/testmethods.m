

%single pass
[x1,y1,u1,v1,snr1]=matpiv('mpim1b.bmp','mpim1c.bmp',64,0.012,0.5,'single','worldco1.mat','polymask.mat');
%single phase pass
[x2,y2,u2,v2,snr2]=matpiv('mpim1b.bmp','mpim1c.bmp',64,0.012,0.5,'phase','worldco1.mat','polymask.mat');
%new multi-step
[x3,y3,u3,v3,snr3]=matpiv('mpim1b.bmp','mpim1c.bmp',[128 128; 64 64; 64 64],0.012,0.5,'multin','worldco1.mat','polymask.mat');
% old three-step multi
[x4,y4,u4,v4,snr4]=matpiv('mpim1b.bmp','mpim1c.bmp',64,0.012,0.5,'multi','worldco1.mat','polymask.mat');
%multi phase
[x5,y5,u5,v5,snr5]=matpiv('mpim1b.bmp','mpim1c.bmp',[128 128;64 64;64 64],0.012,0.5,'multip','worldco1.mat','polymask.mat');
%mqd
[x6,y6,u6,v6,snr6]=matpiv('mpim1b.bmp','mpim1c.bmp',64,0.012,0.5,'mqd','worldco1.mat','polymask.mat');


figure, hold on
h=60; a=2.051; w=8.95;
col={'b.','r.','g.','k.','ro','go'};

for i=1:6
    eval(['u=u',num2str(i),';'])
    eval(['y=y',num2str(i),';'])
    mc=round(size(u,2)/2);
    H(1:length(mc-1:mc+1),i)=plot(u(:,mc-1:mc+1)./(1*a*w),(y(:,mc-1:mc+1)-0.24*h)/(h),col{i});
end

legend(H','single','single phase','multin','multi','multi phase','mqd')