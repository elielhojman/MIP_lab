basefolder = 'sacro/dataset/';

withCanny = 0;

if withCanny
    load('goodBadClassificationsWithCanny');
    data = dataWithCanny;
    badSeg = badSegWithCanny;
    veryBadSeg = veryBadSegWithCanny;
else
    load('goodBadClassificationsNoCanny');
    data = dataNoCanny;
    badSeg = badSegNoCanny;
    veryBadSeg = veryBadSegNoCanny;
end

%% Create the leftBad and rightBad
removeLastChar = @(m)m(1:end-1);
allBad = veryBadSeg;
r = @(m)m;
if iscell(allBad{1})
    allBad = cellfun(r,allBad);
end
% Bad Left
idxL = cellfun(@numel, strfind(allBad,'L'));
leftBad = allBad((idxL~=0));
leftBad = cellfun(removeLastChar,leftBad,'UniformOutput',false);
% Bad Right
idxR = cellfun(@numel, strfind(allBad,'R'));
rightBad = allBad((idxR~=0));
rightBad = cellfun(removeLastChar,rightBad,'UniformOutput',false);

%% Load data
numLeftBad = 0;
numRightBad = 0;

for i = 1:numel(data)
    data{i}.leftBad = 0;
    data{i}.rightBad = 0;
    if sum(strcmp(data{i}.accessNum, leftBad)) > 0
        data{i}.leftBad = 1;
        numLeftBad = numLeftBad + 1;
    end
    if sum(strcmp(data{i}.accessNum, rightBad)) > 0
        data{i}.rightBad = 1;
        numRightBad = numRightBad + 1;
    end    
end


for i = 1:numel(data)
    if isfield(data{i},'score')
        data{i}.score(:,end) = data{i}.score(:,end);
    end
end


dataFull = {};
for i = 1:numel(data)
    if isfield(data{i},'score')        
        sl = [];
        name = [data{i}.accessNum 'L'];
        sl.name = name;
        sl.diagnosis = data{i}.Lt;
        sl.badSeg = data{i}.leftBad;
        sl.noise = data{i}.noise;
        sl.score = data{i}.score(1,:);
        sl.score = processScore(sl.score);
        dataFull{end+1} = sl;
        
        sr = [];
        name = [data{i}.accessNum 'R'];
        sr.name = name;
        sr.diagnosis = data{i}.Rt;
        sr.badSeg = data{i}.rightBad;
        sr.noise = data{i}.noise;
        sr.score = data{i}.score(2,:);
        sr.score = processScore(sr.score);
        dataFull{end+1} = sr;
    end
end

dataGood = {};
j = 1;
for i = 1:numel(dataFull)
    if dataFull{i}.badSeg == 0        
        dataGood{j} = dataFull{i};
        j = j+1;       
    end
end


dataBad = {};
j = 1;
for i = 1:numel(dataFull)
    if dataFull{i}.badSeg == 1        
        dataBad{j} = dataFull{i};
        j = j+1;        
    end
end

% allScores = zeros(1,11);
% for i = 1:numel(dataFull)
%     allScores(i,:) = [dataFull{i}.diagnosis dataFull{i}.badSeg dataFull{i}.score ];
% end


% allScores(:,1) = allScores(:,1) * 1e2;
% allScores(:,2) = allScores(:,2) * 1e2;


