function [ score, cross ] = scoreSegmentation( seg, vol, info, side )
%SCORESEGMENTATION Give a value to the segmentation
sacro = seg == 1 | seg == 4;
ilium = seg == 2 | seg == 3;

pixelSize = info.DicomInfo.PixelSpacing(1);
zPixelSize = info.Scales(3);

R7MM = ceil(7/pixelSize);
R7MM = R7MM*2 + 1;
R3MM = ceil(3/pixelSize);
R3MM = R3MM*2 + 1;

% Excluding the orignal values
XtLeft = zeros(R7MM,R7MM);
diamond = strel('diamond',floor(R7MM/2)); diamond = diamond.getnhood;
mid = round(R7MM/2);
XtLeft(mid:end,:) = diamond(1:mid,:);
XtRight = zeros(R7MM,R7MM);
XtRight(1:mid,:) = diamond(mid:end,:);
if strcmp(side,'right')
    iliumXt = imdilate(ilium,XtLeft);    
    sacroXt = imdilate(sacro,XtRight);
    crossExclude = iliumXt & sacroXt & ~sacro & ~ilium;
else
    iliumXt = imdilate(ilium,XtRight);    
    sacroXt = imdilate(sacro,XtLeft);
    crossExclude = iliumXt & sacroXt & ~sacro & ~ilium;
end

% Not excluding the original values
XtLeft = zeros(R3MM,R3MM);
diamond = strel('diamond',floor(R3MM/2)); diamond = diamond.getnhood;
mid = round(R3MM/2);
XtLeft(mid:end,:) = diamond(1:mid,:);
XtRight = zeros(R3MM,R3MM);
XtRight(1:mid,:) = diamond(mid:end,:);
if strcmp(side,'right')
    iliumXt = imdilate(ilium,XtLeft);    
    sacroXt = imdilate(sacro,XtRight);
    crossInclude = iliumXt & sacroXt;
else
    iliumXt = imdilate(ilium,XtRight);    
    sacroXt = imdilate(sacro,XtLeft);
    crossInclude = iliumXt & sacroXt;
end

CC = bwconncomp(crossExclude,26);
[~,maxIdx] = max(cellfun(@sum,CC.PixelIdxList));
crossExclude = seg & 0;
crossExclude(CC.PixelIdxList{maxIdx}) = 1;
widths = sum(crossExclude,1); xMean = max(widths(widths ~= 0)); xStd = std(widths(widths ~= 0));
widths = sum(sum(crossExclude,1) ~= 0, 2); 
yMax = max(widths(:)); yMean = mean(widths(widths ~= 0)); yStd = std(widths(widths ~= 0));
widths = sum(widths ~= 0,3); zWidth = widths;
grayMean = mean(vol(crossExclude));
totalPx = sum(crossExclude(:));

scoreExclude = [totalPx/(pixelSize.^2*zPixelSize), xMean/pixelSize, xStd/pixelSize , yMax/pixelSize, yMean/pixelSize,...
     yStd/pixelSize, zWidth/zPixelSize, grayMean]; 
 
CC = bwconncomp(crossInclude,26);
[~,maxIdx] = max(cellfun(@sum,CC.PixelIdxList));
crossInclude = seg & 0;
crossInclude(CC.PixelIdxList{maxIdx}) = 1;
widths = sum(crossInclude,1); xMean = max(widths(widths ~= 0)); xStd = std(widths(widths ~= 0));
widths = sum(sum(crossInclude,1) ~= 0, 2); 
yMax = max(widths(:)); yMean = mean(widths(widths ~= 0)); yStd = std(widths(widths ~= 0));
widths = sum(widths ~= 0,3); zWidth = widths;
grayMean = mean(vol(crossInclude));
totalPx = sum(crossInclude(:));

scoreInclude = [totalPx/(pixelSize.^2*zPixelSize), xMean/pixelSize, xStd/pixelSize , yMax/pixelSize, yMean/pixelSize,...
     yStd/pixelSize, zWidth/zPixelSize, grayMean]; 

score = [scoreExclude scoreInclude];
end

