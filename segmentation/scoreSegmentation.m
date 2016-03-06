function [ score, cross ] = scoreSegmentation( seg, vol, info, side )
%SCORESEGMENTATION Give a value to the segmentation
sacro = seg == 1 | seg == 4;
ilium = seg == 2 | seg == 3;

pixelSize = info.DicomInfo.PixelSpacing(1);
zPixelSize = info.Scales(3);
score = [];

[startZ, endZ] = getStartEnd(seg);
totalZ = endZ - startZ;

for i = 1:5
    sacro = imdilate(sacro, ones(3,3));
    cross = sacro & ilium;
    sumRows = sum(cross,1);
    rowsIntersected = numel(find(sumRows));
    score(end+1) = rowsIntersected;
end
score = [score pixelSize zPixelSize totalZ];

