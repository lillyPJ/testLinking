function [wordMulti, charAngleBox] = singleCharAdjust(wordIn, image)

% check input
nWordIn = length(wordIn);
if nWordIn < 1
    wordMulti = [];
    charAngleBox = [];
    return;
end

DEBUG = 0;
%% extract the singleChar word
nChars = [wordIn.nChar];
singleIdx = nChars < 2;
wordSingle = wordIn(singleIdx);
nSingle = length(wordSingle);
wordMulti = wordIn(~singleIdx);
if nSingle < 1
    charAngleBox = [];
    return;
end
%%
% imshow(image);
% displayWordBox(wordSingle);
% disp('ok');
%%
boxes = vertcat(wordSingle.wordbox);
patches = bbApply('crop', image, boxes);
nBox = nSingle;
charAngleBox = boxes;
for i = 1:nBox
    angle = getAngleFromPatch(patches{i});
    charAngleBox(i, 5) = angle;
end
if DEBUG
    imshow(image);
    displayBox(charAngleBox);
    displayAngleBox(charAngleBox, 'b');
end
end

