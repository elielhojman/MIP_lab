function [imgs] = getImagesFromBorderSeg( seg, vol, pixelSz, imgMmSz, pixelImgSz, side )
%GETIMAGESFROMBORDERSEG Summary of this function goes here
%   Detailed explanation goes here
% The vol must be in nifti format
imgs = {};
if side == 'L'
imgSacrumL = getImagesFromBoneSide(seg, vol, 'sacrum','L', pixelSz, imgMmSz, pixelImgSz);
imgIliumL = getImagesFromBoneSide(seg, vol, 'ilium','L', pixelSz, imgMmSz, pixelImgSz);
imgs.sacrum = imgSacrumL;
imgs.ilium = imgIliumL;
else 
imgSacrumR = getImagesFromBoneSide(seg, vol, 'sacrum','R', pixelSz, imgMmSz, pixelImgSz);
imgIliumR = getImagesFromBoneSide(seg, vol, 'ilium','R', pixelSz, imgMmSz, pixelImgSz);
imgs.sacrum = imgSacrumR;
imgs.ilium = imgIliumR;
end

end

function [imgs] = getImagesFromBoneSide(seg, vol, bone, side, pixelSz, imgMmSz, pixelImgSz, oneBone)

if nargin < 8
    oneBone = 0;
end

imgs = {};
if ~strcmp(bone,'sacrum') && ~strcmp(bone,'ilium')
    error('bone must be "sacrum" or "ilium"');
end

if isstruct(seg)
    if side == 'L'
        seg = seg.L;
    else
        seg = seg.R;
    end
end

if oneBone
    sacrum = seg == 1;
    ilium = seg == 1;
    if strcmp(bone,'sacrum')
        vol = vol .* single(~ilium);
    else % ilium
        vol = vol .* single(~sacrum);
    end
end

if strcmp(bone,'sacrum')
    seg = seg == 1;
else % Ilium
    seg = seg == 2;
end

mmJump = ceil(2./pixelSz(1)); % two milimiters jump in the center of image
planeSize = size(seg(:,:,1));
for i = 1:size(seg,3)
    if (pixelSz(2) < 1) && rem(i,3) ~= 0
        continue;
    end
    idxs = find(seg(:,:,i));
    if numel(idxs) > 0
        someIdxs = idxs(1:mmJump:numel(idxs));
        [xS,yS] = ind2sub(planeSize,someIdxs);
    
        for j = 1:numel(xS)
            xyz = [xS(j),yS(j),i];
            xyzImage = getImageFromXYZ(xyz, vol, pixelSz, imgMmSz, pixelImgSz, bone, side);
            s = struct('xyz', xyz,'img',xyzImage);
            imgs{end+1} = s;
        end
    end
end

for i = 1:numel(imgs)
    imgs{i}.img = alignImage(imgs{i}.img);
end


end
 

