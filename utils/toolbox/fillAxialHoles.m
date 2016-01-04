function im_new = fillAxialHoles(mat_seg,R)
%FILLAXIALHOLES Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1
    R = 1;
end
[a, b, c] = size(mat_seg);
im_new = mat_seg;
for i = 1:c
    im = im_new(:,:,i);
    im = reshape(im,a,b);
    im = imdilate(im, strel('square', R));
    im = imfill(im, 'holes');
    im = imerode(im, strel('square', R));
    im_new(:,:,i) = reshape(im, a, b, 1);
end


