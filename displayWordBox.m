function displayWordBox(word, charColor, wordColor)

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
    displayBox(word(i).charbox, charColor);
    displayBox(word(i).wordbox, wordColor);
end
end