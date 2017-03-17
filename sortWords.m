function [wordOut, wordBox, index] = sortWords(wordIn)
% sort according to wordIn.wordbox
nWord = length(wordIn);
wordOut = wordIn;
index = zeros(nWord, 1);
wordBox = zeros(nWord, 4);
if nWord < 1
    return;
end
if nWord < 2
    wordBox = wordOut.wordbox;
    index = 1;
    return;
end
    

% extract wordIn.wordbox, sort according to x
%wordTemp = [wordIn.wordbox];
%wordBox = reshape( wordTemp, [ 4, nWord] )';
wordBox = vertcat(wordIn.wordbox);
[wordBox, index] = sortrows(wordBox);

wordOutTemp = wordOut(index);
wordOut = wordOutTemp;
