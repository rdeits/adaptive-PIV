function randomTest(num)

canvasSize = 200;

figure(1)
hold on;
for i = 1:num,
    x = rand * canvasSize;
    y = rand * canvasSize;
    plot(x,y,'bo')
end
hold off;

end
