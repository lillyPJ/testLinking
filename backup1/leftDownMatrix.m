function data = leftDownMatrix(squareMatrix)
% extract all point(i, j) , j > i
n = size(squareMatrix, 1);

if n < 1
    data = [];
    return;
end
nData = n * (n - 1)/2;
data = zeros(nData, 1);
k = 0;
for i = 1:n
    for j = 1:(i-1)
        k = k + 1;
        data(k) = squareMatrix(i, j);
    end
end
assert(k == nData);