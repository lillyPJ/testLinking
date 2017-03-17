% change test_bb to test_poly
% test_bb: x, y, w, h
% test_poly: x1, y1, x2, y2, x3, y3, x4, y4
DISPLAY = 1;
%% dir and files
TYPE = 'boxWord';
CASE = 'test';
destBase = '.';
testBase = fullfile('/home/lili/datasets/MSRATD500');
sourceDir = fullfile(testBase, 'gt', CASE, 'txt', TYPE);
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
    %         if i < 20
    %             continue;
    %         end
    sourceTestFile = fullfile(sourceDir, gtFilesRawName);
    fprintf('%d:%s\n', i, sourceTestFile);
    imgFileName = fullfile(imgDir, [gtFilesRawName(1:end-3), 'jpg']);
    image = imread(imgFileName);
    
    destTestFile = fullfile(destDir, ['res_', gtFilesRawName]);
    % load test box
    [box, tag] = loadGTFromTxtFile(sourceTestFile);
    
    
    %axis ij
    %     imshow(image);
    %     displayBoxV2(box);
    
    [imgH, imgW, D] = size(image);
    %axis([0, imgW, 0, imgH]);
    %axis on;
    %    if size(box, 1) > 1
    %         box(:, 3) = box(:, 3) - box(:, 1);
    %     box(:, 4) = box(:, 4) - box(:, 2);
    %     newbox  = box;
    %     newbox(:, 5) = (box(:, 1) + box(:, 3))/2;
    %     newbox(:, 6) = (box(:, 2) + box(:, 4))/2;
    %     newbox(:, 7) = box(:, 3).*box(:, 4);
    %     boxLabel = clusterdata(newbox, 3);
    %     box = [box, boxLabel];
    %     displayBox(box, 'g', 'u', 5);
    %    end
    %     box = box';
    %     net = selforgmap([4, 2]);
    %     net = configure(net, box);
    %     plotsompos(net, box);
    %     net.trainParam.epochs = 1000;
    %     net = train(net,box);
    %     plotsompos(net,box);
    
    %axis([0, 2500, 0, 2500]);
    %imshow(image);
    % change box to polys
    polys = [];
    if ~isempty(box)
        box(:,3) = box(:,3) - box(:,1);
        box(:,4) = box(:,4) - box(:,2);
        
        %charWords = boxMerge(box, image);
        tagChar = cell2mat(tag);
        idxEnglish = (tagChar == '1');
        idxChinese = (tagChar == '2');
        boxEnglish = box(idxEnglish, :);
        boxChinese = box(idxChinese, :);
        [wordEnglish, boxCh] =  boxMergeEnglish(boxEnglish);
        boxChinese = [boxChinese; boxCh];
        wordChinese =  boxMergeChinese(boxChinese);
        word = [wordEnglish, wordChinese];
        %word = boxMergeChinese(box);
        %word = boxMergeEnglish(box);
        %charWords = mySelectGroup(box);
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
        polys = round(fromAngleBoxToPoly(angleBoxes));
    end
    
    %saveas(gcf, fullfile(destFigDir, [gtFilesRawName(1:end-3), 'jpg']));
    %show
    if DISPLAY
        imshow(image);
        displayPoly(polys);
    end
    % write to destTestFile
    fp = fopen(destTestFile, 'wt');
    nPoly = size(polys, 1);
    for j = 1:nPoly
        fprintf(fp, '%d, %d, %d, %d, %d, %d, %d, %d\n', polys(j,:));
    end
    fclose(fp);
end

