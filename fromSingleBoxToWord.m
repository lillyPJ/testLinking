function word = fromSingleBoxToWord(box)

% check input
nBox = size(box, 1);
word = [];
if nBox < 1
    return;
end

for i = 1:nBox
    word(i).nChar = 1;
    word(i).charbox = box(i, :);
    word(i).wordbox = box(i, :);
    word(i).meanW = box(i, 3);
    word(i).meanH = box(i, 4);
    word(i).flag  = 1;
    word(i).angle = 0;
end
