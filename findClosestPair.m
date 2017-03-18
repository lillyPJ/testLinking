function minDisIdx = findClosestPair(box)
% box: x, y, w, h
% minDisIdx = [idx1, idx2]

nBox = size(box, 1);
if ~nBox
    minDisIdx = [];
    return;
end

box(:, 5) = box(:, 1) + box(:, 3);
box(:, 6) = box(:, 2) + box(:, 4);
disMatrix = ones(nBox, nBox) * inf;
for i = 1:nBox
    for j = i + 1:nBox
        % horizontal dis
        minXDis = min(abs(box(i, 1) - box(j, 5)), abs(box(j, 1) - box(i, 5)));
        %temp = [xCenter(i), yCenter(i); xCenter(j), yCenter(j)];  
        %dis = norm(diff(temp));
        disMatrix(i, j) = minXDis;
        disMatrix(j, i) = disMatrix(i, j);
    end
end
[row, col] = miniMatrixIdx(disMatrix);
minDisIdx = [row, col];
end

function [row, col] = miniMatrixIdx(A)
if isempty(A)
    row = [];
    col = [];
    return;
end
% A: m*n
minEachCol = min(A); % 1*n
[minValue, col] = min(minEachCol);
row = find(A(:, col) == minValue);
row = row(1);
end