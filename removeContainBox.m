function [newbox, idx] = removeContainBox ( box ,MAXWH, MAXAREA )
% remove the box contained in other box (all the box is in the same group)

if nargin < 2
    MAXWH = inf;
end
if nargin < 3
    MAXAREA = 0.99;
end
if isempty( box )
    newbox = [];
    return;
end

nbox = size( box, 1);
flags = -1*ones( nbox,  1 );
for i =1:nbox
    if flags(i) > 0 
        continue;
    end
    for j = i+1:nbox
        if flags(j) > 0 
            continue;
        end
        containFlag = boxesContain( box(i,:) , box(j,:), MAXAREA );
        if containFlag == 1 && box(j,3)/box(j,4) < MAXWH
            flags(i) = 1;
            break;
        else if containFlag == 2 && box(i,3)/box(i,4) < MAXWH
                    flags(j) = 1;
            end
        end
    end
    if flags(i) < 0
        flags(i) = 0;
    end
end
idx = (flags < 1 );
newbox = box( idx, : );

end

function containFlag = boxesContain( boxA, boxB, MAXAREA )
% containFlag = 1: boxA is inner boxB
% containFlag = 2: boxB is inner boxA
[~, interArea, ~] = calculateOverlap03(  boxA, boxB  );
ratio1 = interArea/ ( boxA(3)  * boxA(4) );
ratio2 = interArea/ ( boxB(3) * boxB(4) );
containFlag  = 0;
if ratio1 > MAXAREA
    containFlag = 1;
else if ratio2 > MAXAREA
        containFlag = 2;
    end
end

end

