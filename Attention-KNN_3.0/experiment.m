clc; clear;
 
% ?????????
M = moviein(16);
% ????
for k = 1:16
   plot(fft(eye(k+16)));
   axis equal;
    % ??getframe???????
   M(k) = getframe;
end
% ??movie?????????M(k)??5?
movie(M, 5);
%%
clc;
clear;
x = 100*rand(100);
y = 100*rand(100);
figure;
Img=cell(length(x)-1,1);
for i =1:length(x)-1
    plot(x(i:i+1),y(i:i+1),'b');
    drawnow;
    axis([0 100 0 200]);
    img= getframe;
    Img{i}=img.cdata;
    hold on;
end
%%
tic;
for i=1:2
    A=rand(1000000,200);
    A_dis = distributed(A);
    [U,s,V]=svds(A_dis,1);
end
toc;

tic;
for i=1:2
    A=rand(1000000,200);
    [U,s,V]=svds(A,1);
end
toc;

