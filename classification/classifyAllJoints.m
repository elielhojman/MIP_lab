%load 'classifier';
fN = 'images/scores/dataset/';
datasetFolder = [fN,'*.mat'];
allFolders = dir(datasetFolder);
threshold = 1.4;
imgPerc = 2.3;
labelsJ = zeros(numel(allFolders),2);
knownLabels = [];
for i = 1:numel(allFolders)
    f = [fN, allFolders(i).name];
    n = allFolders(i).name;
    prediction = classifyJoint(f,threshold,imgPerc);
    knownLabel = getDiagnosisValue(n(1:end-4),diagnosis);
    labelsJ(i,:) = [prediction, (knownLabel>1)+1];
    knownLabels(end+1) = knownLabel;
end
idxsHealthy = labelsJ(:,2) == 1;
mean(labelsJ(idxsHealthy,1) == labelsJ(idxsHealthy,2))
% Sick values
idxsSick = labelsJ(:,2) == 2;
disp('Sick'); mean(labelsJ(idxsSick,1) == labelsJ(idxsSick,2))


%% 
disp('Grade 1');
idxs = knownLabels == 1;
mean(labelsJ(idxs,1) == labelsJ(idxs,2))
disp('Grade 2');
idxs = knownLabels == 2;
mean(labelsJ(idxs,1) == labelsJ(idxs,2))
disp('Grade 3');
idxs = knownLabels == 3;
mean(labelsJ(idxs,1) == labelsJ(idxs,2))
%%
datasetFolder = 'images/dataset/';
fN = 'images/scores/dataset/';
allFolders = dir(datasetFolder);

for i = 1:numel(allFolders)
    % if rand(10,1,1) ~= 1; continue; end;
    f = allFolders(i);
    if (~f.isdir) || size(f.name,2) < 5; continue;  end;
    imFolder = [datasetFolder, f.name];
    imS = imageSet(imFolder);
    [labelIdx, score] = predict(categoryClassifier,imS);
    save([imFolder,'.mat'],'labelIdx', 'score');    
end
%%
tmp = files(filesDiag==3); 
for i = 1:numel(tmp); 
    origF = ['images/dataset/', tmp(i).name]; 
    if i < numel(tmp)/2
        destF = ['images/scores/dataset/',tmp(i).name]; 
    else
        destF = ['images/scores/trainset/',tmp(i).name]; 
    end
    copyfile(origF,destF); 
end;

