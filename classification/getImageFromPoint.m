function [ imgs, imgsBones, imgsFull] = getImageFromPoint( points, imgSzMm, pixelImgSz, randomShift)
%GETIMAGEFROMPOINT Summary of this function goes here
%   imgSize - size specified in milimeters

if nargin < 4
    randomShift = 0;
end

if numel(randomShift) == 1
    randomShift(2) = randomShift(1);
end

if nargin < 2
    imgSzMm = [6 8];
end

if isscalar(imgSzMm) 
   imgSzMm = [imgSzMm imgSzMm];
end
   
matFilePrev = '';
imgs = zeros([pixelImgSz numel(points)]);
imgsFull = {};
imgsBones = {};
for i = 1:numel(points)    
    matFile = ['sacro/dataset/' points{i}.accNum '/' points{i}.accNum '.mat'];
    segFile = ['sacro/dataset/' points{i}.accNum '/segmentationNoCanny'];
    if ~strcmp(matFilePrev, matFile) % Need to load new image
        load(matFile);
        matFilePrev = matFile;
        load(segFile);
        vol = dicom2niftiVol(vol,dicomInfo);
        display(dicomInfo.Scales);
    end
   
    % To enrich our dataset
    if randomShift(1) > 0
        points{i}.x = points{i}.x + randi(randomShift(1),1,1);
        points{i}.y = points{i}.y + randi(randomShift(2),1,1);
    end
    bone = getRelevantBone(points{i},seg.L + seg.R);    
    xyz = [points{i}.x, points{i}.y, points{i}.z];
    img = getImageFromXYZ(xyz, vol, dicomInfo.Scales(1:2), imgSzMm, pixelImgSz, bone, points{i}.side);
    imgs(:,:,i) = img;
end

imgs = alignImage(imgs);
end

function [bone] = getRelevantBone(point, seg)
bone = '';
ilium = seg == 2 | seg == 3;
sacrum = seg == 1 | seg == 4;
iliumSlice = ilium(:,:,point.z);
sacrumSlice = sacrum(:,:,point.z);
p = zeros(size(seg(:,:,1)));
p(point.x,point.y) = 1;
for i = [1 3 5 7];
    ps = imdilate(p,strel('square',i));
    iliumInt = iliumSlice & ps;
    sacrumInt = sacrumSlice & ps;
    if sum(iliumInt(:)) + sum(sacrumInt(:)) == 0
        continue;
    end
    if sum(iliumInt(:)) > sum(sacrumInt(:))
        bone = 'ilium';
        return;
    else
        bone = 'sacrum';
        return;
    end
end
end
