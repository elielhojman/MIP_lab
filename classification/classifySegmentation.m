function [res, labels, imgs] = classifySegmentation(svmstruct, seg, vol, pixelSz)
imgMmSz = [14 14];
pixlImgSz = round(imgMmSz/0.25);
imgs = getImagesFromBorderSeg( seg, vol, pixelSz, imgMmSz, pixlImgSz );
labels = [];
for j = 1:numel(imgs)
    blockImgs = getBlocks(imgs{j}.img, [16 16], [36 36], 4);
    blockImgs = blockImgs';
    res = svmclassify(svmstruct,blockImgs);
    if mean(res - 1) > 0.8
        label = 2;
    else
        label = 1;
    end
    labels(end+1)  = label;
end

if sum(labels == 2) > 10
    res = 2;
else
    res = 1;
end
