function wordOut = boxMergeChinese1(wordIn)

% check input
nWordIn = length(wordIn);
wordOut = wordIn;
if nWordIn < 1
    return;
end
%
DEBUG = 0;
%
TH_DISX_W = 0.75; %0.75
TH_DISY = 0.75;
%TH_MAXAR = 1.8;
TH_WH_V = 1.6;
TH_HW_V = 2.2; %2.2
TH_H = 1.5; %1.5
TH_W = 1.5; %1.5
TH_S = 2;
TH_INV_DISX = 0.5;
%% sort
[wordOutSort, wordBoxSort] = sortWords(wordIn);
%% precomputing
boxes = wordBoxSort(:, 1:4);
nbox = nWordIn;
xCenter = floor(boxes(:, 1) + boxes(:, 3) / 2); %xCenter
yCenter = floor(boxes(:, 2) + boxes(:, 4) / 2); %yCenter
wh = boxes(:, 3) ./ boxes(:, 4); % wh = w/h
hw = 1./wh; % hw = h/w
s = boxes(:, 3) .* boxes(:, 3); % s = w*h!!!!!3 ->4
%s = (boxes(:, 3) .* boxes(:, 3) + boxes(:, 4) .* boxes(:, 4))./2; % s = w*h
maxAR = max(wh, hw); % maxAR = max(wh, hw)
for i = 1:nbox
    char(i) = struct('left',[],'right',[]);
end
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
        miniH = min(boxes(i, 4), boxes(j, 4));
        disX_W = abs(abs(xCenter(i) - xCenter(j)) - meanW) / miniH;
       
        disY = abs(yCenter(i) - yCenter(j)) /miniH;
        wRatio = max(boxes(i, 3)/boxes(j, 3), boxes(j, 3)/boxes(i, 3));
        hRatio = max(boxes(i, 4)/boxes(j, 4), boxes(j, 4)/boxes(i, 4));
        sRatio = max(s(i)/s(j), s(j)/s(i));
        if disX_W < TH_DISX_W && ...
                disY < TH_DISY && ...
                wh(i) < TH_WH_V && wh(j) < TH_WH_V && ...
                hw(i) < TH_HW_V && hw(j) < TH_HW_V &&...
                hRatio < TH_H && ...
                wRatio < TH_W && ...
                sRatio < TH_S 
                
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
    wordOut(i).flag = 2; % multi
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
    wordOut(k).flag = 1; % single
    wordOut(k).angle = 0;
    k = k +1;
end
%displayWordBox(wordOut);
% disp('ok');
end

