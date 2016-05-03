traindata = {};

N = length(dataGood);
scores = zeros(N,size(dataGood{1}.score,2));
group = zeros(N,1);
for i = 1:N
    scores(i,:) = dataGood{i}.score;
    group(i) = dataGood{i}.diagnosis > 0;
end
scoresC = scores(:,:);
K = 10;
indices = crossvalind('Kfold',group,K);
cp = classperf(group);
for i = 1:K
    test = (indices == i); train = ~test;
    class = classify(scoresC(test,:),scoresC(train,:),group(train,:));
    classperf(cp,class,test);
end
cp.ErrorRate

svmstruct = svmtrain(scores, group);
groupC = svmclassify(svmstruct, scores);
diff = groupC - group;
falseGood = sum(diff == 1)
falseBad = sum(diff == -1) % With condition that appear as that there is none


