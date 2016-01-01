function im_new = fillHoles(mat_seg,R)
%FILLHOLES Summary of this function goes here
%   Detailed explanation goes here

% Fill holes in skeleton
display('Filling holes');
if nargin == 1
    R = 1;
end
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


