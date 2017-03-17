function word = fromSingleBoxToWord(box)

% check input
nBox = size(box, 1);
word = [];
if nBox < 1
    return;
end

for i = 1:nBox
    word(i).charbox = box(i, :);
    word(i).wordbox = box(i, :);
end
