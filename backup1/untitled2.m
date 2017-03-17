%指定输入二维向量及其类别 
P = [-3 -2 -2   0   0   0   0 +2 +2 +3;   
      0 +1 -1 +2 +1 -1 -2 +1 -1   0]; 
C = [1 1 1 2 2 2 2 1 1 1]; 
%将这些类别转换成学习向量量化网络使用的目标向量 
T = ind2vec(C) 
%用不同的颜色，绘出这些输入向量 
plotvec(P,C), 
title('输入二维向量'); 
xlabel('P(1)'); 
ylabel('P(2)'); 
%建立网络 
net = newlvq(minmax(P),4,[.6 .4],0.1); 
%在同一幅图上绘出输入向量及初始权重向量 
figure; 
plotvec(P,C) 
hold on 
W1=net.iw{1}; 
plot(W1(1,1),W1(1,2),'ow') 
title('输入以及权重向量'); 
xlabel('P(1), W(1)'); 
ylabel('P(2), W(2)'); 
hold off; 
%训练网络，并再次绘出权重向量 
figure; 
plotvec(P,C); 
hold on; 
net.trainParam.epochs=150; 
net.trainParam.show=Inf; 
net=train(net,P,T); 
plotvec(net.iw{1}',vec2ind(net.lw{2}),'o'); 
%对于一个特定的点，得到网络的输出 
p = [0.8; 0.3]; 
a = vec2ind(sim(net,p))
