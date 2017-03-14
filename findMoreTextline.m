function newWords = findMoreTextline(box)

%% check input
newWords = [];
nBox = size(box, 1);
if nBox < 1
    return;
end
if nBox < 3 % 1~2
    newWords.nChar = 1;
    newWords.charbox = box;
    newWords.wordbox = box;
    return;
end
%box(:, 5) = 1:nBox;
%displayBox(box, 'g', 'm', 5);
%% calculate the angleMatrix
xCenter = box(:, 1) + box(:, 3)/2;
yCenter = box(:, 2) + box(:, 4)/2;
angleMatrix = zeros(nBox, nBox);
for i = 1:nBox
    for j = i + 1:nBox
        angle = (yCenter(j) - yCenter(i))/(xCenter(j) - xCenter(i));
        angleMatrix(i, j) = angle;
        angleMatrix(j, i) = angle;
    end
end
while(nBox > 2)
    %% analys the angleHist
    amin = min(min(angleMatrix)) - 0.5;
    amax = max(max(angleMatrix)) + 0.5;
    step = 1/nBox;
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
    allBinIdx = [maxIdx, find(binIdx(maxIdx,:)== maxBinIdx(maxIdx))];
    if maxN < 2 % box less than three
        data = leftDownMatrix(angleMatrix);
        [sumNB, sumBin] = histc(data, range);
        [maxN, maxIdx] = max(sumNB);
        allBinIdx = find(sumBin == maxIdx);
        % more than two
        % (find the most possible pattern)--repeated
        allBinIdx = allBinIdx(1); % select the first one
        idxX = round(sqrt(allBinIdx * 2));
        idxY = allBinIdx - idxX * (idxX - 1) / 2; % K = i*(i-1)/2 + j
        idxX = idxX + 1;
        allBinIdx = [idxX, idxY];
        
    end
    nIdx = length(allBinIdx);
    tempWord.nChar = nIdx;
    tempWord.charbox = box(allBinIdx, :);
    tempWord.wordbox = mmbox(box(allBinIdx, :));
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
    tempWord.nChar = nBox;
    tempWord.charbox = box;
    tempWord.wordbox = mmbox(box);
    newWords = [newWords, tempWord];
end