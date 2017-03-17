function displayWordPoly(word, charColor, wordColor)

assert(nargin > 0);
if nargin < 3
    wordColor = 'b';
end
if nargin < 2
    charColor = 'g';
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
    displayAngleBox(angleBox);
end
end