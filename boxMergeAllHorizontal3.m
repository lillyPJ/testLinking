function wordOut = boxMergeAllHorizontal3(wordIn)

% check input
wordOut = [];
if length(wordIn) < 1
    return;
end

%%
DEBUG = 0;
TH_ANGLE = 8/180*pi;
TH_DISX_W = 1.5;
TH_DISY = 0.8;
%% refinement : get angle for each word

wordIn = refineWord(wordIn);
if length(wordIn) < 1
    return;
end
nWordIn = length(wordIn);
%% sort
[wordOutSort, wordBoxSort] = sortWords(wordIn);
boxes = wordBoxSort(:, 1:4);
nbox = nWordIn;
xCenter = floor(boxes(:, 1) + boxes(:, 3) / 2); %xCenter
yCenter = floor(boxes(:, 2) + boxes(:, 4) / 2); %yCenter
angles = [wordOutSort.angle];
for i = 1:nbox
    char(i) = struct('left',[],'right',[]);
end
%
if DEBUG
    boxes(:, 5) = 1:nbox;
    displayBox(boxes, 'g', 'u', 5);
end
%% group left child and right child
for i = 1:nWordIn
    if DEBUG
        displayBox(boxes(i, :), 'b');
    end
    for j = i+1:nWordIn
        if DEBUG
            displayBox(boxes(j, :), 'y');
        end
        meanW = mean([boxes(i, 3), boxes(j, 3)]);
        minW = min(boxes(i, 3), boxes(j, 3));
        minH = min(boxes(i, 4), boxes(j, 4));
        maxH = max(boxes(i, 4), boxes(j, 4));
        angleCenter = atan((yCenter(j) - yCenter(i))/(xCenter(j) - xCenter(i)));
        angleDiff = min(abs(angleCenter - angles(i)), abs(angleCenter - angles(j)));
        disX_W = abs(abs(xCenter(i) - xCenter(j)) - meanW) / minH;
        disY = abs(yCenter(i) - yCenter(j)) /maxH;
        if angleDiff < TH_ANGLE && ...
                disX_W < TH_DISX_W && ...
                disY < TH_DISY
            if boxes(i, 1) <= boxes(j, 1)
                char(i).right = [char(i).right, j];
                char(j).left = [char(j).left, i];
            else
                char(i).left = [char(i).left, j];
                char(j).right = [char(j).right, i];     
            end
        end
    end
end
%% generate word by merging chars
SG = cell(nbox, 1);
for i = 1:nbox
    n1 = size(char(i).left,2);
    n2 = size(char(i).right,2);
    if ( n1 ~= 0 || n2 ~= 0 )
        set1 = char(i).left ;
        set2 = char(i).right;
        unionChar = unique(  [set1, set2] );
        SG{i} = [unionChar,i];
    end
end
newSG = unionSet(SG, 1);
%% output word
wordOut = [];
% word of multi char
nWordOut = length( newSG );
for i =1: nWordOut
    idx = newSG{i};
    charBoxes = vertcat(wordOutSort(idx).charbox);
    wordOut(i).nChar = size(charBoxes, 1);
    wordOut(i).charbox = charBoxes;
    wordOut(i).wordbox = mmbox(boxes(idx, :));
    wordOut(i).meanW = mean(charBoxes(:, 3));
    wordOut(i).meanH = mean(charBoxes(:, 4)); 
    wordOut(i).flag = 32;    
    wordOut(i).angle = 0;
end
% word of single char
if nWordOut > 0
    idxWordChar = [newSG{:}];
else
    idxWordChar = [];
end
idxAll = 1:nWordIn;
idxSingleChar = setdiff(idxAll, idxWordChar);
nSingle =  length(idxSingleChar);
k = nWordOut +1;
for i = 1:nSingle
    charBoxes = vertcat(wordOutSort(idxSingleChar(i)).charbox);
    wordOut(k).nChar = size(charBoxes, 1);
    wordOut(k).charbox = charBoxes;
    wordOut(k).wordbox = boxes(idxSingleChar(i), :);
    wordOut(k).meanW = mean(charBoxes(:, 3));
    wordOut(k).meanH = mean(charBoxes(:, 4));  
    wordOut(k).flag = 31;  
    wordOut(k).angle = 0;
    k = k +1;
end

%% display
%newWords = refineWord(wordOut);
% displayWordBox(wordOut);
% displayWordPoly(wordOut, 'm');
% %displayWordBox(wordOut);
%disp('ok');