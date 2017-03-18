function word = boxMergeAll(box)
%% check input
word = [];
if isempty(box)
    return;
end

%% from single box to word
word = fromSingleBoxToWord(box);


%% mergeChinese1
word = boxMergeChinese1(word);


%% MergeEnglish2
word = boxMergeEnglish2(word);

%% MergeLast3
%word = boxMergeLast3(word);
%% MergeSingleChar3
[word, wordSingle, wordMulti] = boxMergeSingle3(word);


%% MergeSingleChar3
%[word, wordSingle, wordMulti] = boxMergeSingle3(word);
%% mergeAllHorizontal3
%word = boxMergeAllHorizontal3(word);
% word = [wordSingle, wordMulti];
%word = boxMergeAllHorizontal3(word); %!!!!!!!!!!!
%% mergeAllVertical4
%word = boxMergeAllVertical4(word);
%% refine word
word = refineWord(word);



%% output
%displayWordBox(word);
%displayWordPoly(word, 'm');
end


function newSet = unionSet( set , numInterSect)
% input  and output are cell
nSet = length( set );
newSet = [];
mark = 1;
while mark
    mark = 0;
    for i = 1: nSet-1
        set1 = set{i};
        if isempty(set1)
            continue;
        end
        for j = i+1:nSet
            set1 = set{i};
            set2 =  set{j};
            if isempty(set2)
                continue;
            end
            interSet = intersect(set1, set2);
            if length(interSet) > numInterSect
                set{i} = union(set1,set2);
                set{j} = [];
                mark = 1;
            end
        end
    end
end
for i = 1: nSet
    if ~isempty( set{i} )
        newSet = [newSet; set(i)];
    end
end
end


function [word, multiWord, singleChar] = mergeWords(charbox, params)
%% check input
if nargin < 2
    THeightRatio = 1.8;%高度比 % = 2.1, 52.6/// = 2.1 use to the textLine method
    TXDIF = 2;%水平间距 % =2 , 62.5/// =3 use to the textLine method
    TYDIF = 0.8;%垂直间距
    TDIS = 100;
    TXDIFMIN  = 0.25;
else
    THeightRatio = params.THeightRatio;%高度比 % = 2.1, 52.6/// = 2.1 use to the textLine method
    TXDIF = params.TXDIF;%水平间距 % =2 , 62.5/// =3 use to the textLine method
    TYDIF = params.TYDIF;%垂直间距
    TDIS = params.TDIS;
    TXDIFMIN = params.TXDIFMIN;
end

word = [];
multiWord  = [];
singleChar = [];
if isempty(charbox)
    return;
end
%% single char merged to a textline
charbox = sortrows(charbox);
boxes = charbox(:, 1:4);
nbox = size(boxes,1);
for i = 1:nbox
    char(i) = struct('left',[],'right',[]);
    %SG(i) = struct('cc',[]);
    xCenter = boxes(i,1)+floor(boxes(i,3)/2);
    yCenter = boxes(i,2)+floor(boxes(i,4)/2);
    boxes(i,5) = xCenter;
    boxes(i,6) = yCenter;
end
%imshow(image);
% boxes(:, 7) = 1:nbox;
% displayBox(boxes, 'g', 'u', 7);
%% union the left and right neighbor of each char
for i = 1:nbox-1
    xi1 = boxes(i,1);
    wi = boxes(i,3);
    xi2 = xi1 + wi;
    
    hi = boxes(i,4);
    xiCenter = boxes(i,5);
    yiCenter = boxes(i,6);
    hwi = hi/wi;
    
    for j = i+1:nbox
        xj1 = boxes(j,1);
        wj = boxes(j,3);
        xj2 = xj1 + wj;
        hj = boxes(j,4);
        xjCenter = boxes(j,5);
        yjCenter = boxes(j,6);
        hwj = hj/wj;
       
        disX = min(abs(xi1 - xj2), abs(xj1 - xi2));
        %TXDIF = max(0.75, TXDIF * max(hwi, hwj));
        if ( (1/THeightRatio < (hi/hj) && (hi/hj) < THeightRatio) && ... 
                ( abs(xiCenter-xjCenter) < TXDIF*max(wi,wj)) &&...
                ( abs(yiCenter-yjCenter) < TYDIF*max(hi,hj)) && ...
                abs(xiCenter-xjCenter) > TXDIFMIN*max(wi,wj)/max(hwi,hwj) && ...
                disX < TDIS) ...) % different!
            if xi1<= xj1
                right_num_1 = size(char(i).right,2);
                left_num_2 = size(char(j).left,2);
                char(i).right(right_num_1+1) = j;
                char(j).left(left_num_2+1) = i;     
            else
                left_num_1 = size(char(i).left,2);
                right_num_2 = size(char(j).right,2);
                char(i).left(left_num_1+1) = j;
                char(j).right(right_num_2+1) = i;
            end
        end
        
    end
end
%% generate words by merging chars
SG = cell(nbox, 1);
for i = 1:nbox
    n1 = size(char(i).left,2);
    n2 = size(char(i).right,2);
    %if ( n1 ~= 0 || n2 ~= 0 ) &&(abs(n1-n2) <= 3)
    %if n1 ~= 0&&n2 ~= 0&&(abs(n1-n2) <= 3)
    if ( n1 ~= 0 || n2 ~= 0 )
        set1 = char(i).left ;
        set2 = char(i).right;
        unionChar = unique(  [set1, set2] );
        SG{i} = [unionChar,i];
    end
end
newSG = unionSet( SG, 1);
word = [];
% char of word
nWord = length( newSG );
for i =1: nWord
    idx = newSG{i};
    nChar = length( idx );
    word(i).nChar = nChar;
    word(i).charbox = boxes( idx,1:4);
    word(i).wordbox = mmbox( boxes(idx,:) );
end
if nWord > 0
    idxWordChar = [newSG{:}];
else
    idxWordChar = [];
end
%% multi word
multiWord = word;
%% single char
idxAll = 1:nbox;
idxSingleChar = setdiff( idxAll, idxWordChar);
nSingle =  length( idxSingleChar);
k = nWord +1;
singleChar = [];
for i = 1:nSingle
    word(k).nChar = 1;
    word(k).charbox = boxes(idxSingleChar(i),1:4);
    singleChar = [singleChar; word(k).charbox];
    word(k).wordbox = word(k).charbox;
    k = k +1;
end
if isempty( word )
    return;
end
end