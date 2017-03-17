function displayWordPoly(word, wordColor)

assert(nargin > 0);
if nargin < 2
    wordColor = 'b';
end
% check input
nWord = length(word);
if nWord < 1
    return;
end

% displayWord
for i = 1:nWord
    angle = myPolyFit(word(i).charbox);
    angleBox = getPolyFromBox(word(i).wordbox, angle);
    displayAngleBox(angleBox, wordColor);
end
end