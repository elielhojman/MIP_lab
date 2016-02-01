function [ bonesSeg ] = getBones( volume, fill, minTh )
% function to get the bone segmentation on a volume
% INPUT:
%    volume - The matrix image
%    fill - boolean value to perform filling of holes in each of the 3D
%    planes
%    minTh - imin Threshold
% We do a threshold segmentation based on maxTh (locally fixed)
% and minTh. minTh is an optional argument, in case not provided 
% it is determined by searching for the minimum number of components
% between 150:500.

global maxTh;
maxTh = 1300;
R = 3;
% Search i_min
if ~exist('minTh','var')
    minTh = searchMinTh(volume); 
end

bonesSeg = volume < maxTh & volume > minTh;
 %% Getting the greatest connected component
hipZoom = isHipsZoom(bonesSeg);
if hipZoom
    R = 7;
else
    bonesSeg = bwareaopen(bonesSeg, 4000, 26);
end
bonesSeg = imdilate(bonesSeg, strel('square', R));
CC = bwconncomp(bonesSeg, 26);
numPixels = cellfun(@numel, CC.PixelIdxList);
[~,maxIdx] = max(numPixels);
bonesSeg = zeros(size(volume),'int8');
bonesSeg(CC.PixelIdxList{maxIdx}) = 1;
bonesSeg = imerode(bonesSeg, strel('square', R));
if ~exist('fill','var') && fill == 1
 bonesSeg = fillHoles(bonesSeg);
end

end

%% minTh search function
function minTh = searchMinTh(volume)

global maxTh;
X = 150:20:500;
components = [];

for i = 1:size(X,2);
    minTh = X(i);
    imgSeg = volume < maxTh & volume > minTh;    
    CC = bwconncomp(imgSeg, 26);
    display(['i_min = ', num2str(minTh), ...
        ', conncomp = ', num2str(CC.NumObjects)])
    components(end+1) = CC.NumObjects;
end

[num_comp, min_idx] = min(components);
minTh = X(min_idx);
display(['i_min = ', num2str(minTh),'. #Components ', num2str(num_comp)]);
end


