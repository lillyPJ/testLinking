function [angle, error] = myPolyFit(box)
% check input
angle = 0;
error = 0;
nBox = size(box, 1);
if nBox < 2
    return;
end

% polyfit 
xCenter = box(:, 1) + box(:, 3)/2;
yCenter = box(:, 2) + box(:, 4)/2;
[p, s] = polyfit(xCenter, yCenter,1);
if (abs(p(1)) > 1) % angle > 45
    p(1) = -1/p(1);
end
angle = atan(p(1));
% calculate error
if(nBox > 2) % two point: error = 0
    [y, delta]= polyval(p, xCenter, s);
    error= var(delta);
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