% change test_bb to test_poly
% test_bb: x, y, w, h
% test_poly: x1, y1, x2, y2, x3, y3, x4, y4
clear all
DISPLAY = 0;
addpath('/home/lili/codes/evaluationPoly');
%% dir and files
TYPE = 'boxWord';
CASE = 'test';
destBase = '.';
testBase = fullfile('/home/lili/datasets/MSRATD500');
sourceDir = fullfile(testBase, 'gt', CASE, 'txt', TYPE);
gtDir = fullfile(testBase, 'gt', 'test', 'txt', 'polyTextline');
imgDir = fullfile(testBase, 'img', CASE);
destDir = fullfile(destBase, TYPE);
destFigDir = fullfile(destBase, 'fig', TYPE);
mkdir(destFigDir);
mkdir(destDir);
%% process each file
files = dir(fullfile(sourceDir, '*.txt'));
nFile = numel(files);

for i = 1:nFile
    gtFilesRawName = files(i).name;
%     if i < 53
%         continue;
%     end
    sourceTestFile = fullfile(sourceDir, gtFilesRawName);
    fprintf('%d:%s\n', i, sourceTestFile);
    imgFileName = fullfile(imgDir, [gtFilesRawName(1:end-3), 'jpg']);
    image = imread(imgFileName);
    
    destTestFile = fullfile(destDir, ['res_', gtFilesRawName]);
    % load test box
    [box, tag] = loadGTFromTxtFile(sourceTestFile); 
    gtFile = fullfile(gtDir, gtFilesRawName);
    gtPoly = importdata(gtFile);
    [imgH, imgW, D] = size(image);
    %axis([0, imgW, 0, imgH]);

    dtPoly = [];
    if ~isempty(box)
        box(:,3) = box(:,3) - box(:,1);
        box(:,4) = box(:,4) - box(:,2);
        
        %charWords = boxMerge(box, image);
%         tagChar = cell2mat(tag);
%         idxEnglish = (tagChar == '1');
%         idxChinese = (tagChar == '2');
%         boxEnglish = box(idxEnglish, :);
%         boxChinese = box(idxChinese, :);
%         [wordEnglish, boxCh] =  boxMergeEnglish(boxEnglish);
%         boxChinese = [boxChinese; boxCh];
%         wordChinese =  boxMergeChinese(boxChinese);
%         word = [wordEnglish, wordChinese];
%        
        imshow(image);
        % mergeAll
        word = boxMergeAll(box);
        
        
        nWord = length( word );
        angleBoxes = zeros(nWord, 5);
        for j = 1:nWord
            [angle, error] = myPolyFit(word(j).charbox);
            %displayBox(word(i).wordbox, 'b');
            %displayBox(word(i).charbox, 'g');
            angleBox = getPolyFromBox(word(j).wordbox, angle);
            %angleBox = adjustBoxPercent(angleBox, [0.005, 0.1]);
            angleBoxes(j, :) = angleBox;
            
            %displayAngleBox(angleBox, 'm');
        end
        dtPoly = round(fromAngleBoxToPoly(angleBoxes));
    end
    
    %saveas(gcf, fullfile(destFigDir, [gtFilesRawName(1:end-3), 'jpg']));
    %show
    if DISPLAY
        imshow(image);
        displayPoly(dtPoly);
        displayPoly(gtPoly, 'r');
    end
    [recall, precision, fscore, evalInfo(i)] = evalDetPoly(dtPoly, gtPoly);
    fprintf('recall = %.3f, precision = %.3f, f-score = %.3f\n', recall, precision, fscore);
    
    % write to destTestFile
    %     fp = fopen(destTestFile, 'wt');
    %     nPoly = size(polys, 1);
    %     for j = 1:nPoly
    %         fprintf(fp, '%d, %d, %d, %d, %d, %d, %d, %d\n', polys(j,:));
    %     end
    %     fclose(fp);
end

% total
recall =  sum( [evalInfo.tr] ) / sum( [evalInfo.nG] );
precision = sum( [evalInfo.tp] ) / sum( [evalInfo.nD] );
if recall + precision > 0
    fscore = 2 * recall * precision / (recall + precision);
else
    fscore = 0;
end
fprintf('\nrecall = %.3f, precision = %.3f, fmeasure = %.3f\n', recall, precision, fscore);