function [wordOut, wordSingle, wordMulti] = boxMergeSingle3(wordIn)

% check input
nWordIn = length(wordIn);
wordOut = [];
if nWordIn < 1
    return;
end

DEBUG = 0;
%% extract the singleChar word
nChars = [wordIn.nChar];
singleIdx = nChars < 2;
wordSingle = wordIn(singleIdx);
nSingle = length(wordSingle);
wordMulti = wordIn(~singleIdx);
if nSingle < 2
    wordOut = wordIn;
    return;
end
%%
TH_DISX_W = 0.8;
TH_DISY = 0.8;
%TH_MAXAR = 1.8;
TH_H = 5; %1.5
TH_INV_DISX = 0.35;
TH_SH = 0.7;
TH_WH = 1.1; %0.9
%% sort
[wordOutSort, wordBoxSort] = sortWords(wordSingle);
%% precomputing
boxes = wordBoxSort(:, 1:4);
nBox = nSingle;
xCenter = floor(boxes(:, 1) + boxes(:, 3) / 2); %xCenter
yCenter = floor(boxes(:, 2) + boxes(:, 4) / 2); %yCenter
wh = boxes(:, 3) ./ boxes(:, 4); % wh = w/h
hw = 1./wh; % hw = h/w
maxAR = max(wh, hw); % maxAR = max(wh, hw)
for i = 1:nBox
    char(i) = struct('left',[],'right',[]);
end
if DEBUG
    boxes(:, 5) = 1:nBox;
    displayBox(boxes, 'g', 'u', 5);
end
%
%% group left child and right child
for i = 1:nBox
    if DEBUG
        displayBox(boxes(i, :), 'b');
    end
    for j = i+1:nBox
        if DEBUG
            displayBox(boxes(j, :), 'y');
        end
        meanW = mean([boxes(i, 3), boxes(j, 3)]);
        meanH = mean([boxes(i, 4), boxes(j, 4)]); 
        minW = min(boxes(i, 3), boxes(j, 3));
        minH = min(boxes(i, 4), boxes(j, 4));
        hRatio = max(boxes(i, 4)/boxes(j, 4), boxes(j, 4)/boxes(i, 4));
        disX_W = abs(abs(xCenter(i) - xCenter(j)) - meanW);
        disY_H = abs(abs(yCenter(i) - yCenter(j)) - meanH);
        disX = abs(xCenter(i) - xCenter(j)) / minW;
        disY = abs(yCenter(i) - yCenter(j)) / minH;
        
        flag = 0;
        % 1. close enough (x,y)
        if disX_W / minW < 0.5 && disY_H / minH < 0.7 && ...
                hw(i) < 2 && hw(j) < 2
            flag = 1;
        end
        % 2. horizontal, Chinese char
        if disX_W / minW< 4 && disY < 0.3 && ...
                hw(i) < 1.8 && hw(j) < 1.8 && wh(i) < 1.3 && wh(j) < 1.3 &&...
                hRatio < 1.2
            flag = 1;
        end
        % 3. vertical, Chinese/English char
        if disX < 0.3 && disY_H / minW < 1.3 && ...
                hw(i) > 0.65 && hw(j) > 0.65 %&& wh(i) < 1.4 && wh(j) < 1.4
            flag = 1;
        end
        
        
        if flag     
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
SG = cell(nBox, 1);
for i = 1:nBox
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
idxAll = 1:nBox;
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
wordSingle = wordOut;
%displayWordBox(wordOut);
wordOut = [wordSingle, wordMulti];
%% display
% newWords = refineWord(wordOut);
%displayWordBox(wordOut);
% displayWordPoly(newWords, 'm');
% %displayWordBox(wordOut);
% disp('ok');

end
%}