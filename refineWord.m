function newWords = refineWord(words)
% 
nWord = length( words );
newWords = [];
if nWord < 1
    return;
end
newWords = [];
for i = 1:nWord
%     displayBox(words(i).charbox, 'g');
%     displayBox(words(i).wordbox, 'b');
    [angle, error] = myPolyFit(words(i).charbox);
    if error < 3/words(i).nChar % error threshold
        words(i).angle = angle;
        newWords = [newWords, words(i)];
    else
        % one "words" has one more than one textline
        tempWords = findMoreTextline(words(i).charbox); 
        newWords = [newWords, tempWords];
    end
end
end