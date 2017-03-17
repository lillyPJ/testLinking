function newWords = findMoreTextline(box)

%% check input
newWords = [];
nBox = size(box, 1);
if nBox < 1
    return;
end
if nBox < 3 % 1~2
    newWords.charbox = box;
    newWords.wordbox = box;
    tempWord.meanW = mean(box(:, 3));
    tempWord.meanH = mean(box(:, 4));
    tempWord.flag = 23; %single
    return;
end
% box(:, 5) = 1:nBox;
% displayBox(box, 'g', 'm', 5);
%% calculate the angleMatrix
xCenter = box(:, 1) + box(:, 3)/2;
yCenter = box(:, 2) + box(:, 4)/2;
angleMatrix = zeros(nBox, nBox);
for i = 1:nBox
    for j = i + 1:nBox
        if (xCenter(j) - xCenter(i)) < 1 % nearly vertical
            angle = (yCenter(j) - yCenter(i));
        else
            angle = (yCenter(j) - yCenter(i))/(xCenter(j) - xCenter(i));
        end
        angleMatrix(i, j) = angle;
        angleMatrix(j, i) = angle;
    end
end
while(nBox > 2)
    %% analys the angleHist
    amin = min(min(angleMatrix));
    amax = max(max(angleMatrix));
    amin = amin - (amax - amin)/30;
    amax = amax + (amax - amin)/30;
    step = 1.1/nBox;
    %step = 0.15;
    if step > (amax - amin)
        step = (amax - amin)/5;
    end
    range = amin:step:amax;
    nBin = [];
    binIdx = [];
    
    for i = 1:nBox
        histData = angleMatrix(i,:);
        histData(i) = [];
        [nb, bin] = histc(histData, range);
        nBin = [nBin; nb];
        newBin = [bin(1:i-1), -1, bin(i:nBox-1)];
        binIdx = [binIdx; newBin];
        %bar(range, nBin(i,:), 'histc');
    end
    %% find one group with the highest maxBin
    [maxCenterIdx, maxBinIdx] = max(nBin, [], 2);
    [maxN, maxIdx] = max(maxCenterIdx);
    if maxN == mean(maxCenterIdx)
        % each group has the same number of box
        % find the one with the smallest variance
        vars = zeros(nBox, 1);
        for i = 1:nBox
            allBinIdx = [i, find(binIdx(i,:)== maxBinIdx(i))];
            vars(i) = var(angleMatrix(i, allBinIdx));
        end
        [~, maxIdx] = min(vars);
    end
    allBinIdx = [maxIdx, find(binIdx(maxIdx,:)== maxBinIdx(maxIdx))];
    %     if maxN < 2 % box less than three
    %         data = leftDownMatrix(angleMatrix);
    %         [sumNB, sumBin] = histc(data, range);
    %         [maxN, maxIdx] = max(sumNB);
    %         allBinIdx = find(sumBin == maxIdx);
    %         % more than two
    %         % (find the most possible pattern)--repeated
    %         allBinIdx = allBinIdx(1); % select the first one
    %         idxX = round(sqrt(allBinIdx * 2));
    %         idxY = allBinIdx - idxX * (idxX - 1) / 2; % K = i*(i-1)/2 + j
    %         idxX = idxX + 1;
    %         allBinIdx = [idxX, idxY];
    %
    %     end
    nIdx = length(allBinIdx);
    tempWord.charbox = box(allBinIdx, :);
    tempWord.nChar = size(tempWord.charbox, 1);
    tempWord.wordbox = mmbox(box(allBinIdx, :));
    tempWord.meanW = mean(box(allBinIdx, 3));
    tempWord.meanH = mean(box(allBinIdx, 4));
    tempWord.flag = 24; %multi
    tempWord.angle = myPolyFit(tempWord.charbox);
    newWords = [newWords, tempWord];
    %% delete the vertex in the group and update the angleMatrix
    box(allBinIdx, :) = [];
    angleMatrix(allBinIdx, :) = [];
    angleMatrix(:, allBinIdx, :) = [];
    xCenter(allBinIdx, :) = [];
    yCenter(allBinIdx, :) = [];
    nBox = nBox - nIdx;
end
% nBox ~[1, 2]
if nBox > 0
    tempWord.charbox = box;
    tempWord.nChar = size(tempWord.charbox, 1);
    tempWord.wordbox = mmbox(box);
    tempWord.meanW = mean(box(:, 3));
    tempWord.meanH = mean(box(:, 4));
    tempWord.flag = 23; %single
    tempWord.angle = myPolyFit(tempWord.charbox);
    newWords = [newWords, tempWord];
end