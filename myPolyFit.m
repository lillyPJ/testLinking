function [angle, error] = myPolyFit(box)

angle = [];
error = 0;
if isempty(box)
    return;
end
if size(box, 1) < 2
    angle = 0;
    return;
end
xCenter = box(:, 1) + box(:, 3)/2;
yCenter = box(:, 2) + box(:, 4)/2;

[p, s] = polyfit(xCenter, yCenter,1);
if (abs(p(1)) > 1) % angle > 45
    p(1) = -1/p(1);
end
angle = atan(p(1));
[y, delta]= polyval(p, xCenter, s);
if(size(box,1) > 2) % two point: error = 0
    error= var(delta);
end

if error > 4
    data = [xCenter, yCenter];
    A = [];
    n = size(data, 1);
    d = 2;
    for i=1:n
        A(i,:) = [xCenter(i), yCenter(i),-1];
    end
%     for i=1:n
%         A(i+n,:) = [yCenter(i)',1];
%     end
    c = ones(n,1)*(-1);
    %show the data
    H = eye(d+1);
    H(d+1,d+1) = 0;
    w = quadprog(H, zeros(d+1,1),A,c);
    %refline(w(1), w(2));
    hold on;
    x1 = 1:1:1000;
    y1 = (1-w(3)-w(1)*x1)/w(2);
    plot(x1,y1,'g-','LineWidth',10);
end
% %
% hold on;
% x1=linspace(min(xCenter),max(yCenter));
% y1=polyval(p,x1);
% plot(xCenter,y,'*',x1,y1);
%refline(p(1), p(2));
% line(xCenter, y, 'color', 'r');
% plot(xCenter, yCenter, 'oy');
% fprintf('error = %.3f\n', error);