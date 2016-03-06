% basefolder = 'sacro/dataset/';
% for i = 1:numel(data)
%     data{i}.leftBad = 0;
%     data{i}.rightBad = 0;
%     if sum(strcmp(data{i}.accessNum, leftBad)) > 0
%         data{i}.leftBad = 1;
%     end
%     if sum(strcmp(data{i}.accessNum, rightBad)) > 0
%         data{i}.rightBad = 1;
%     end    
% end
% 
% 
% for i = 1:numel(data)
%     if isfield(data{i},'score')
%         data{i}.score(:,end) = data{i}.score(:,end)/1e6;
%     end
% end
% 
% dataBad = {};
% j = 1;
% for i = 1:numel(data)
%     if data{i}.leftBad == 1 || data{i}.rightBad == 1
%         if isfield(data{i},'score')
%             dataBad{j} = data{i};
%             j = j+1;
%         end
%     end
% end
% 
% dataGood = {};
% j = 1;
% for i = 1:numel(data)
%     if data{i}.leftBad == 0 && data{i}.rightBad == 0
%         if isfield(data{i},'score')
%             dataGood{j} = data{i};
%             j = j+1;
%         end
%     end
% end

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
        dataFull{end+1} = sl;
        
        sr = [];
        name = [data{i}.accessNum 'R'];
        sr.name = name;
        sr.diagnosis = data{i}.Rt;
        sr.badSeg = data{i}.rightBad;
        sr.noise = data{i}.noise;
        sr.score = data{i}.score(2,:);
        dataFull{end+1} = sr;
    end
end

allScores = zeros(1,11);
for i = 1:numel(dataFull)
    allScores(i,:) = [dataFull{i}.diagnosis dataFull{i}.badSeg dataFull{i}.score ];
end

allScores(:,1) = allScores(:,1) * 1e2;
allScores(:,2) = allScores(:,2) * 1e2;


