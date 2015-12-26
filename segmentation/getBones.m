function [ bonesSeg ] = getBones( volume, minTh )
% function to get the bone segmentation on a volume
%
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

bonesSeg = bwareaopen(bonesSeg, 4000, 26);
bonesSeg = imdilate(bonesSeg, strel('square', R));
CC = bwconncomp(bonesSeg, 26);
numPixels = cellfun(@numel, CC.PixelIdxList);
[~,maxIdx] = max(numPixels);
bonesSeg = zeros(size(volume));
bonesSeg(CC.PixelIdxList{maxIdx}) = 1;
bonesSeg = imerode(bonesSeg, strel('square', R));
% bonesSeg = fillHoles(bonesSeg);

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


function im_new = fillHoles(mat_seg)
% Fill holes in skeleton
R = 3;
[a, b, c] = size(mat_seg);
im_new = mat_seg;
for i = 1:a
    im = im_new(i,:,:);
    im = reshape(im,b,c);
    im = imdilate(im, strel('square', R));
    im = imfill(im, 'holes');
    im = imerode(im, strel('square', R));
    im_new(i,:,:) = reshape(im, 1, b, c);
end


for i = 1:b
    im = im_new(:,i,:);
    im = reshape(im,a,c);
    im = imdilate(im, strel('square', R));
    im = imfill(im, 'holes');
    im = imerode(im, strel('square', R));
    im_new(:,i,:) = reshape(im, a, 1, c);
end

for i = 1:c
    im = im_new(:,:,i);
    im = reshape(im,a,b);
    im = imdilate(im, strel('square', R));
    im = imfill(im, 'holes');
    im = imerode(im, strel('square', R));
    im_new(:,:,i) = reshape(im, a, b, 1);
end
end
