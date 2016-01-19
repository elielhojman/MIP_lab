function [ noise ] = getNoiseValue( vol )
%GETNOISEVALUE We take small patches int ehvolume and calculate their std
%              Images with large noise will have a greater std.
ITERS = 1000;
PSIZE = 3;
[rows, cols, slices] = size(vol);
center2d = round([rows/2 cols/2]);
middle = round(slices/2);
deviation = zeros(1,ITERS);
for i = 1:ITERS
    center = center2d + randn(1,2)*50;
    center = round(center);
    slice = middle + randn(1)*5;
    slice = round(slice);
    patch = vol(center(1):center(1)+PSIZE, ...
                center(2):center(2)+PSIZE, ...
                slice);
    deviation(i) = std(double(patch(:)));
end

noise = mean(deviation);

