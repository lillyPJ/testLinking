function newLine = mergeTextLine ( textLine )
newLine = [];
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
box = sortrows( box, 6);
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
    return;
end
crossSetIdx = unique( mergeSet(:) );
if size( crossSetIdx, 1) > 1
    crossSetIdx = crossSetIdx';
end
% add the normal box
restIdx = setdiff( [1:nLine], crossSetIdx );
newLine = [newLine; box( restIdx, 1:4) ];
% add the merge box
mergeSetCell = num2cell( mergeSet, 2);
newMergeSetCell = unionSet( mergeSetCell );
nMerge = size( newMergeSetCell, 1); 
for i = 1:nMerge
    idx = newMergeSetCell{i};
    boxes = box( idx,: );
    newLine = [newLine; mmbox( boxes )];
end
% imshow( image );
% displayBox( textLine );
% displayBox( newLine, 'b' );
% disp('ok');
end

function newSet = unionSet( set )
% input  and output are cell
nSet = size( set, 1);
newSet = [];
for i = 1: nSet
    flag = 1;
    for j = i + 1: nSet
        if ~isempty( intersect( set{i}, set{j}) )
            set{j} = union( set{i}, set{j} );
            flag = 0;
        end
    end
    if flag
        newSet = [newSet; set(i)];
    end
end
end
            