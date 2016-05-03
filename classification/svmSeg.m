traindata = {};
for i = 1:length(data)
    if isfield(data{i},'score') && size(data{i}.score,1) == 2
        sL = struct('score',data{i}.score(1,:), 'group',1,'side','L','accN',data{i}.accessNum);
        sR = struct('score',data{i}.score(2,:), 'group',1,'side','R','accN',data{i}.accessNum);
        if sum(cellfun(@sum,strfind(leftBad,data{i}.accessNum)))
            sL.group = 0;
        end
        if sum(cellfun(@sum,strfind(rightBad,data{i}.accessNum)))
            sR.group = 0;
        end
        traindata{end+1} = sR;
        traindata{end+1} = sL;
    end
end

N = length(traindata);
scores = zeros(N,9);
group = zeros(N,1);
for i = 1:N
    scores(i,:) = traindata{i}.score;
    group(i) = traindata{i}.group;
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
falseBad = sum(diff == -1)


