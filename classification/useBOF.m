%imgSetsN = imageSet('images/imgs_uint_N','recursive');
imgSetsP1 = imageSet('images/imgDiag1','recursive');
imgSetsP2 = imageSet('images/imgDiag2','recursive');
imgSetsP3 = imageSet('images/imgDiag3','recursive');
imgSetsN = imageSet('images/trainset/healthy','recursive');
imgSetsP = imageSet('images/trainset/sick','recursive');
%imgSetsP = imageSet('images/trainset/sick23','recursive');
% imgSets = [imgSetsN imgSetsP1 imgSetsP2 imgSetsP3];
imgSets = [imgSetsN imgSetsP];
[testSet, trainSet] = partition(imgSets, 0.2,'randomized');

%% bag = bagOfFeatures(trainSet,'GridStep',[4 4],'StrongestFeatures',0.6,'VocabularySize',200,'BlockWidth',[32 64 128]);
% bag = bagOfFeatures(trainSet);
bag = bagOfFeatures(trainSet,'CustomExtractor',@myBagOfFeaturesExtractor,'VocabularySize',200);
categoryClassifier = trainImageCategoryClassifier(trainSet, bag);
% .71, .64
disp('Train set');
[confMatrix,knownLabelTr, predictionLabelTr] = evaluate(categoryClassifier, trainSet);

disp('Test set');
[confMatrix, knownLabelTst, predictionLabelTst, scoreTst] = evaluate(categoryClassifier, testSet);

%%
gradeTr = [];
gradeTst = [];
for i = 1:trainSet(2).Count
    f = trainSet(2).ImageLocation{i};
    [~,f] = fileparts(f);
    idxStr = strsplit(f,'_');
    idxStr = idxStr(1);
    idx = str2double(idxStr);
    gradeTr(end+1) = diagnosisLbls(idx);
end

gradeTst = [];
for i = 1:testSet(2).Count
    f = testSet(2).ImageLocation{i};
    [~,f] = fileparts(f);
    idxStr = strsplit(f,'_');
    idxStr = idxStr(1);
    idx = str2double(idxStr);
    gradeTst(end+1) = diagnosisLbls(idx);
end

%%
disp('Grade 1 Train')
k = 1;
mean(knownLabelTr(gradeTr == k) == predictionLabelTr(gradeTr == k))
disp('Grade 2 Train')
k = 2;
mean(knownLabelTr(gradeTr == k) == predictionLabelTr(gradeTr == k))
disp('Grade 3 Train')
k = 3;
mean(knownLabelTr(gradeTr == k) == predictionLabelTr(gradeTr == k))

disp('Grade 1 Test')
k = 1;
mean(knownLabelTst(gradeTst == k) == predictionLabelTst(gradeTst == k))
disp('Grade 2 Test')
k = 2;
mean(knownLabelTst(gradeTst == k) == predictionLabelTst(gradeTst == k))
disp('Grade 3 Test')
k = 3;
mean(knownLabelTst(gradeTst == k) == predictionLabelTst(gradeTst == k))