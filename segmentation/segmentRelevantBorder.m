function [ seg ] = segmentRelevantBorder( origSeg, side, bone, pixelSz, pixelZSz )
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
beginningOfJoint = findBeginningOfJoint(intersection);
JOINT_MARGIN = ceil(35/pixelSz);
jointArea = zeros(size(origSeg),'int8');
jointArea(:,beginningOfJoint:beginningOfJoint+JOINT_MARGIN,:) = 1;
[~,topZslice] = find(sum(sum(intersection,1),2),1,'last');
SLICE_MARGIN = ceil(8/pixelZSz);
seg = intersection & jointArea;

try
    seg(:,:,topZslice-SLICE_MARGIN:topZslice) = 0;
catch
    disp('Problem trying to add the SLICE_MARGIN');
end

if side == 'R'
    if strcmp(bone,'sacrum')
        seg = getBoundary(seg,'R');
    else
        seg = getBoundary(seg,'L');
    end
else
    if strcmp(bone,'ilium')
        seg = getBoundary(seg,'R');
    else
        seg = getBoundary(seg,'L');
    end
end

% for i = 1:size(origSeg,3)
% %     CC = bwconncomp(intersection(:,:,i),8);
% %     slice = seg(:,:,1) .* 0;
% %     [~,maxIdx] = max(cellfun(@numel,CC.PixelIdxList));
% %     slice(CC.PixelIdxList{maxIdx}) = 1;
%     seg(:,:,i) = maxPixelsYAligned(intersection(:,:,i));
% end

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


function [front] = findBeginningOfJoint(intersection)
% We calculate here the beginning of the joint
% This is the most-front pixel of the intersection between the sacrum and
% ilium. This will be the general reference to take from here 25mm
% corresponding to the size of the joint
front = Inf;
for i = 1:size(intersection,3)
    slice = intersection(:,:,i);
    if max(slice(:)) > 0
        candidate = find(sum(slice,1),1,'first');
        if candidate < front
            front = candidate;
        end
    end
end
end
    
