function word = mergeAll(box)
%% check input
word = [];
if isempty(box)
    return;
end

%% divide English and Chinese
wh = box(:, 3)./box(:, 4);
boxChinese = box(wh < 1.2, :);
boxEnglish = box(wh >= 1.2, :);


idxEnglish = (tagChar == '1');
idxChinese = (tagChar == '2');
boxEnglish = box(idxEnglish, :);
boxChinese = box(idxChinese, :);
[wordEnglish, boxCh] =  boxMergeEnglish(boxEnglish);
boxChinese = [boxChinese; boxCh];
wordChinese =  boxMergeChinese(boxChinese);
word = [wordEnglish, wordChinese];
