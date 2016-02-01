function [ score, cross ] = scoreSegmentation( seg, vol, info )
%SCORESEGMENTATION Give a value to the segmentation
sacro = seg == 1 | seg == 4;
ilium = seg == 2 | seg == 3;

R = 17;
iliumXt = imdilate(ilium,strel('square',R));
sacroXt = imdilate(sacro,strel('square',R));
cross = iliumXt & sacroXt & ~sacro & ~ilium;

pixelSize = info.DicomInfo.PixelSpacing(1);
zPixelSize = info.Scales(3);
totalPx = sum(cross(:));
CC = bwconncomp(cross,26);
[~,maxIdx] = max(cellfun(@sum,CC.PixelIdxList));
cross = seg & 0;
cross(CC.PixelIdxList{maxIdx}) = 1;
widths = sum(cross,1); xMean = max(widths(widths ~= 0)); xStd = std(widths(widths ~= 0));
widths = sum(sum(cross,1) ~= 0, 2); 
yMax = max(widths(:)); yMean = mean(widths(widths ~= 0)); yStd = std(widths(widths ~= 0));
widths = sum(widths ~= 0,3); zWidth = widths;
grayMean = mean(vol(cross));

score = [totalPx, xMean/pixelSize, xStd/pixelSize , yMax/pixelSize, yMean/pixelSize,...
     yStd/pixelSize, zWidth/zPixelSize, grayMean]; 
end

