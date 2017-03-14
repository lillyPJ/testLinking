function word = boxMergeEnglish(charbox)
%%boundbox:为窗口集合；img:为彩色图；
%boxes[x,y,w,h]
%boxes[x,y,w,h,xcenter,ycenter,area,color]
if isempty( charbox )
    word = [];
    return;
end
%% =======================horizontal===================
params.THeightRatio = 3;%高度比 % = 2.1, 52.6/// = 2.1 use to the textLine method
params.TXDIF = 1.3;%水平间距 % =2 , 62.5/// =3 use to the textLine method
params.TYDIF = 0.75;%垂直间距
params.TDIS = 40;
params.TXDIFMIN  = 0.45;
[word1, multiWord1, singleChar] = mergeWords(charbox, params);
%% =======================single char:vertical===================
% params.THeightRatio = 1.5;
% params.TXDIF = 5;
% params.TYDIF = 3;
% %displayBox(singleChar, 'b');
% [word2, multiWord, singleChar] = mergeWords(singleChar, params);
%% output and show test
word = refineWord(word1);
%% =======================merge textline===================
% params.THeightRatio = 3;%高度比 % = 2.1, 52.6/// = 2.1 use to the textLine method
% params.TXDIF = 1.3;%水平间距 % =2 , 62.5/// =3 use to the textLine method
% params.TYDIF = 0.75;%垂直间距
% wordTemp = [word2.wordbox];
% nWord = length( wordTemp )/4;
% textLine = reshape( wordTemp, [ 4, nWord] )';
% % [~, idx1] = removeContainBox ( textLine );
% [word, newLine] = mergeTextline ( word2, textLine );

% params.THeightRatio = 4;%高度比 % = 2.1, 52.6/// = 2.1 use to the textLine method
% params.TXDIF = 1.5;%水平间距 % =2 , 62.5/// =3 use to the textLine method
% params.TYDIF = 0.3;%垂直间距
% params.TDIS = 0.5;
% params.TXDIFMIN  = 0.45;
% 
% wordTemp = [word.wordbox];
% nWord = length( wordTemp )/4;
% textLine = reshape( wordTemp, [ 4, nWord] )';
% word2 = mergeWords(textLine, params);
% nWord = length(word2);
% for i = 1:nWord
%     displayBox(word2(i).wordbox, 'b');
%     displayBox(word2(i).charbox, 'g');
%     %angleBox = getPolyFromBox(word(i).wordbox, angle);
% %     displayAngleBox(angleBox, 'm');
% end

%imshow( image );
nWord = length( word );
for i = 1:nWord
    [angle, error] = myPolyFit(word(i).charbox);
    displayBox(word(i).wordbox, 'b');
    displayBox(word(i).charbox, 'g');
    angleBox = getPolyFromBox(word(i).wordbox, angle);
    displayAngleBox(angleBox, 'm');
end
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
    TDIS = 40;
    TXDIFMIN  = 0.45;
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
    
    for j = i+1:nbox
        xj1 = boxes(j,1);
        wj = boxes(j,3);
        xj2 = xj1 + wj;
        hj = boxes(j,4);
        xjCenter = boxes(j,5);
        yjCenter = boxes(j,6);
        
        disX = min(abs(xi1 - xj2), abs(xj1 - xi2));
        if ( (1/THeightRatio < (hi/hj) && (hi/hj) < THeightRatio) && ... 
                ( abs(xiCenter-xjCenter) < TXDIF*max(wi,wj)) &&...
                ( abs(yiCenter-yjCenter) < TYDIF*max(hi,hj)) && ...
                abs(xiCenter-xjCenter) > TXDIFMIN*max(wi,wj) && ...
                disX < 100) ...) % different!
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

function [newWord, newLine] = mergeTextline ( word, textLine )
newLine = [];
newWord = [];
% textLine = removeContainBox ( textLine );
nLine = size( textLine, 1);
if nLine < 1
    return;
end
%% paras
MINIDIS = 1/2;
MINXGAP = 2;
%%
box = textLine;
box(:, 5) = box(:, 2) + box(:, 4);% box(5)-down, box(6)-ycenter
box(:, 6) = ( box(:, 2) + box(:, 5) )/2;

% sort according to the ycenter
[box, sortIdx] = sortrows( box, 6);
word = word( sortIdx );
xcenter = floor (box(: ,1) + box(:, 3) /2 );
% calculate the seg
upRow = [box(:, 6); 0];
downRow = [ 0; box(:,6)];
gapTemp = upRow - downRow;
gap = gapTemp(2: end-1);
crossIdx = find( gap < 50 );
nCross = length( crossIdx );
if nCross < 1   
    newLine = box(:, 1:4);
    newWord = word;
    return;
end
mergeSet = [];
for i =1: nCross
    maxW = max( box( crossIdx(i), 3 ), box( crossIdx(i) + 1, 3 ) );
    maxH = max( box( crossIdx(i), 4 ), box( crossIdx(i) + 1, 4 ) );
    upGap = abs( box( crossIdx(i), 2 ) - box( crossIdx(i) + 1, 2 ) ) /maxH;
    downGap = abs( box( crossIdx(i), 5 ) - box( crossIdx(i) + 1, 5 ) ) /maxH;
    xcenterGap = abs( xcenter(crossIdx(i)) - xcenter(crossIdx(i) + 1) )  / maxW ;
    if(  upGap < MINIDIS && downGap < MINIDIS  && xcenterGap < MINXGAP )
        % crossIdx(i) and crossIdx(i) + 1 need to be merged
        mergeSet = [mergeSet; crossIdx(i), crossIdx(i) + 1 ];
      end
end
if isempty( mergeSet )
    newLine = box(:, 1:4);
    newWord = word;
    return;
end
crossSetIdx = unique( mergeSet(:) );
if size( crossSetIdx, 1) > 1
    crossSetIdx = crossSetIdx';
end
% add the normal box
restIdx = setdiff( [1:nLine], crossSetIdx );
newLine = [newLine; box( restIdx, 1:4) ];
newWord = [newWord; word(restIdx)];
% add the merge box
mergeSetCell = num2cell( mergeSet, 2);
newMergeSetCell = unionSet( mergeSetCell, 0 );
nMerge = size( newMergeSetCell, 1); 
for i = 1:nMerge
    idx = newMergeSetCell{i};
    boxes = box( idx,: );
    newLine = [newLine; mmbox( boxes )];
    charBoxes = [];
    for k = idx
        charBoxes = [charBoxes; word(k).charbox];
    end
    newTemp.charbox = charBoxes;
    newTemp.nChar = size(charBoxes, 1);
    newTemp.wordbox = mmbox( charBoxes );
    newWord = [newWord, newTemp];
end
assert( size(newLine,1) == length( newWord ) );
% imshow( image );
% displayBox( textLine );
% displayBox( newLine, 'b' );
% disp('ok');
end