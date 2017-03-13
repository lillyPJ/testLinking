function word = boxMerge(charbox, image)
%% 通过有效的整合，达到整合滑动窗口的目的；
%%boundbox:为窗口集合；img:为彩色图；
%boxes[x,y,w,h]
%boxes[x,y,w,h,xcenter,ycenter,area,color]
if isempty( charbox )
    word = [];
    return;
end
%%
T1 = 1.8;%高度比 % = 2.1, 52.6/// = 2.1 use to the textLine method
T2 = 2;%水平间距 % =2 , 62.5/// =3 use to the textLine method
T3 = 0.8;%垂直间距
T4 = 100;%面积比
T5 = 600;%颜色差
Tangle = 75/180*pi;
% 6. 要求两个box没有互相包含关系
T6 = 100;%高宽比
charbox = sortrows(charbox);
%% single char merged to a textline
boxes = charbox(:, 1:4);
nbox = size(boxes,1);
patches = bbApply( 'crop', image, boxes );
for i = 1:nbox
    char(i) = struct('left',[],'right',[]);
    %SG(i) = struct('cc',[]);
    xCenter = boxes(i,1)+floor(boxes(i,3)/2);
    yCenter = boxes(i,2)+floor(boxes(i,4)/2);
    boxes(i,5) = xCenter;
    boxes(i,6) = yCenter;
    boxes(i,7) = boxes(i,3)*boxes(i,4);
    boxes(i,8) = mean( mean( mean( patches{i}) ) );
end
%imshow(image);
boxes(:, 9) = 1:nbox;
%displayBox(boxes, 'g', 'u', 9);
%% union the left and right neighbor of each char
for i = 1:nbox-1
    xi1 = boxes(i,1);
    %yi1 = boxes(i,2);
    wi = boxes(i,3);
    hi = boxes(i,4);
    xiCenter = boxes(i,5);
    yiCenter = boxes(i,6);
    %     xi2 = xi1 + wi -1;
    %     yi2 = yi1 + hi -1;
    si = boxes(i,7);
    ci = boxes(i,8);
    hwi = hi/wi;
    
    for j = i+1:nbox
        xj1 = boxes(j,1);
        % yj1 = boxes(j,2);
        %         xj2 = xj1 + wj -1;
        %         yj2 = yj1 + hj -1;
        wj = boxes(j,3);
        hj = boxes(j,4);
        xjCenter = boxes(j,5);
        yjCenter = boxes(j,6);
        sj = boxes(j,7);
        cj = boxes(j,8);
        hwj = hj/wj;
        angle = atan(abs((yjCenter - yiCenter)/(xjCenter - xiCenter)));
%         if angle < Tangle
%             T3 = 0.8;
%         else
%             T3 = 3;
%         end
        if ( (1/T1 <= (hi/hj) && (hi/hj) <= T1) && ... %高度比<2.1 (最大/最小）
                ( abs(xiCenter-xjCenter) <= T2*max(wi,wj)) &&...%质心水平距离x差< = 最大宽度的2.5倍
                ( 1/T4 <= si/sj && si/sj <= T4) &&...%面积比< = 6倍
                ( abs(ci-cj) <= T5)   &&...%颜色差< = 50 % AIsInB([x1,y1,w1,h1], [x2,y2,w2,h2]) == 0 &&...%不互相包含
                1/T6<hwi/hwj && hwi/hwj<T6  &&...) %高宽比< = 7%不把横条的进行分组
            ( abs(yiCenter-yjCenter) <= T3*min(hi,hj)) ) %&&...%质心竖直距离y< = 最大高度的0.5倍
                
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
    %  if n1 ~= 0&&n2 ~= 0&&(abs(n1-n2) <= 3)
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
% single char
idxAll = 1:nbox;
idxSingleChar = setdiff( idxAll, idxWordChar);
% if input boxes has more than four dimension (5 = score)
if size( charbox, 2) > 4
    idxSingleChar = idxSingleChar( charbox(idxSingleChar, 5 ) > 0 ) ;
end
nSingle =  length( idxSingleChar);
k = nWord +1;
for i = 1:nSingle
    word(k).nChar = 1;
    word(k).charbox = boxes(idxSingleChar(i),1:4);
    word(k).wordbox = word(k).charbox;
    k = k +1;
end
if isempty( word )
    return;
end
%% remove the contain word and negative box
% wordTemp = [word.wordbox];
% nWord = length( wordTemp )/4;
% textLine = reshape( wordTemp, [ 4, nWord] )';
% % [~, idx1] = removeContainBox ( textLine );
% [newWord, newLine] = mergeWords ( word, textLine );
%  [newLine, idx1] = removeContainBox ( newLine );
% word = newWord( idx1 );
% [newLine, idx2]  = stringClassificationHOG_SVM( image, newLine, model );
% word = newWord( idx2 );
% imshow( image );
% displayBox( boxes, 'r' ); % filtered
% displayBox( boxes(idxWordChar,:) ); % word
% displayBox( boxes(idxSingleChar,:), 'b'); % single

%imshow( image );
%displayBox( newLine, 'm' );
nWord = length( word );
% for i =1:nWord
%     displayBox( word(i).charbox, 'b' );
%     displayBox( word(i).wordbox, 'g' );
% end
for i = 1:nWord
    angle = myPolyFit(word(i).charbox);
    angleBox = getPolyFromBox(word(i).wordbox, angle);
    displayAngleBox(angleBox);
end
%displayBox( newLine );
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

function [newWord, newLine] = mergeWords ( word, textLine )
newLine = [];
newWord = [];
% textLine = removeContainBox ( textLine );
nLine = size( textLine, 1);
if nLine < 1
    return;
end
%% paras
MINIDIS = 1/5;
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
crossIdx = find( gap < 10 );
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