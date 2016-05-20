function [ seg ] = segmentRelevantBorder( origSeg, side, bone, pixelSz )
%SEGMENTRELEVANTBORDER Summary of this function goes here
%   Detailed explanation goes here

if ~strcmp(bone,'sacrum') && ~strcmp(bone,'ilium')
    error('Bone must be either "sacrum" or "ilium"');
end

if isstruct(origSeg)
    if side == 'L'
        origSeg = origSeg.L;
    else
        origSeg = origSeg.R;
    end
end

[sacrum, ilium] = getSacrumIliumFromSeg(origSeg);
d = ceil(3.5/pixelSz); % We dilate 3.5 mm
filterForPlane = zeros(2*d,2*d,3);
filterForPlane(:,:,2) = 1;

if strcmp(bone,'ilium') % we expand the sacrum
    boneD = imdilate(sacrum,filterForPlane);
    myBone = ilium;
else % bone == 'sacrum'
    boneD = imdilate(ilium,filterForPlane);
    myBone = sacrum;
end

intersection = boneD & myBone;
seg = origSeg .* 0;

for i = 1:size(origSeg,3)
%     CC = bwconncomp(intersection(:,:,i),8);
%     slice = seg(:,:,1) .* 0;
%     [~,maxIdx] = max(cellfun(@numel,CC.PixelIdxList));
%     slice(CC.PixelIdxList{maxIdx}) = 1;
           
      seg(:,:,i) = maxPixelsYAligned(intersection(:,:,i));
end

end


function [newSlice] = maxPixelsYAligned(image)
    newSlice = image .* 0;
    CC = bwconncomp(image,8);
    ff = @(m)ind2sub(size(image),m);
    [xS,yS] = cellfun(ff,CC.PixelIdxList,'UniformOutput',false);
    xSUnique = cellfun(@unique,yS,'UniformOutput',false);
    [~,maxIdx] = max(cellfun(@numel,xSUnique));
    newSlice(CC.PixelIdxList{maxIdx}) = 1;
end

