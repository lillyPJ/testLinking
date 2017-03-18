function angle = getAngleFromPatch(wordPatch)

if isempty(wordPatch)
    angle = [];
    return;
end
img = wordPatch;
%% preprocess
imggray = rgb2gray(img);
imgfft = fft2(imggray);
imgfft = abs(imgfft);
imgfft = log(imgfft);
imgfft = mat2gray(imgfft);
imgfft = im2uint8(imgfft);
imgshift = fftshift(imgfft);
imgBw = im2bw(imgshift,0.6);

% subplot(1, 2, 1);
% imshow(img);
% subplot(1, 2, 2);
% imshow(imgBw);
%% hough lines detect
topK = 1;
[H1, T1, R1] = hough(imgBw,'Theta', 10:0.1:85);
Peaks1 = houghpeaks(H1, topK);
lines1 = houghlines(imgBw, T1, R1, Peaks1);
[H2, T2, R2] = hough(imgBw,'Theta',-85:0.1:-10);
Peaks2 = houghpeaks(H2,topK);
lines2 = houghlines(imgBw, T2, R2, Peaks2);
lines = [lines1; lines2];

if isempty(lines)
    angle = 0;
    return;
end
%% lines to point
xs1 = [lines1.point1];
xs2 = [lines2.point1];
ys1 = [lines1.point2];
ys2 = [lines2.point2];
% if isempty(lines1)
%     xs = [lines2.point1];
%     ys = [lines2.point2];
% else
%     xs = [lines1.point1];
%     ys = [lines1.point2];
% end
[imgH, imgW, D] = size(img);
subplot(1, 2, 1);
imshow(imgBw);
subplot(1, 2, 2);
imshow(img);
%% angle
if ~isempty(xs1)
    angle11 = (ys1(2) - ys1(1))/(xs1(2) - xs1(1));
    angle12 = -1/angle11;
    angle = angle12;
    box11 = [imgW/3, imgH/2, imgW/2, 5, atan(angle11)];
    box12 = [imgW/3, imgH/2, imgW/2, 5, atan(angle12)]; 
    displayAngleBox(box11, 'g');
    displayAngleBox(box12, 'g');
end
if ~isempty(xs2)
    angle21 = (ys2(2) - ys2(1))/(xs2(2) - xs2(1));
    angle22 = -1/angle21;
    angle = angle21;
    box21 = [imgW/3, imgH/2, imgW/2, 5, atan(angle21)];
    box22 = [imgW/3, imgH/2, imgW/2, 5, atan(angle22)];  
    displayAngleBox(box21, 'b');
    displayAngleBox(box22, 'b');
end
%% show
disp('ok');


