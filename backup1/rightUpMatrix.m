function data = rightUpMatrix(squareMatrix)
% extract all point(i, j) , j > i
nCol = size(squareMatrix, 1);

if nCol < 1
    data = [];
    return;
end
nData = nCol * (nCol - 1)/2;
data = zeros(nData, 1);
k = 0;
for i = 1:nCol
    for j = i + 1: nCol
        k = k + 1;
        data(k) = squareMatrix(i, j);
    end
end
assert(k == nData);