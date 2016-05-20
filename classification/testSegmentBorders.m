
accNumsDone = {};
for j = 1:2
    if j == 1
        segList = goodSegNoCanny;
    end
    
    if j == 2
        segList = badSegNoCanny;
    end
    
    for i = 1:numel(segList)        
        accNum = segList{i};        
        accNum = accNum(1:end-1);
        display(accNum);
        if sum(strcmp(accNumsDone,accNum)) == 1
            continue;
        end            
        accNumsDone{end+1} = accNum;
        load(['sacro/dataset/', accNum,'/segmentationNoCanny.mat']);

        pixelSz = info.score(1,end-3);
        segBorder = segmentRelevantBorders(seg,pixelSz);
        segBones = seg;
        save(['sacro/dataset/', accNum,'/segBorder.mat'],'segBorder','info','segBones');
    end
end

%% For badSegs
% for i = randi(numel(badSegNoCanny),1,10)
%     accNum = badSegNoCanny{i};
%     accNum = accNum(1:end-1);
%     load(['sacro/dataset/', accNum,'/segmentationNoCanny.mat']);
%     
%     pixelSz = info.score(1,end-3);
%     segNew = segmentRelevantBorders(seg,pixelSz);
%     saveSegAndDicom(['sacro/dataset/', accNum],segNew, 'bordersSeg');
% end 
