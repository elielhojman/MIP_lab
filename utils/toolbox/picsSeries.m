function [ output_args ] = picsSeries( seg, volume, outfile )
%PICSSERIES Output a series of pictures showing the segmentation
[startS, endS] = getStartEnd(seg);
sq = getMaxConvhullSquare(seg, startS, endS);
rows = sq(2) - sq(1) + 1;
cols = sq(4) - sq(3) + 1;

sizeIm = [rows cols 3];
red = zeros(sizeIm); red(:,:,1) = 255;
blue = zeros(sizeIm); blue(:,:,2) = 255;
green = zeros(sizeIm); green(:,:,3) = 255;
yellow = zeros(sizeIm); yellow(:,:,1) = 255; yellow(:,:,2) = 255;
alpha = zeros(sizeIm) + 0.2;
slices = round(linspace(startS, endS, 18));
fh = figure('Position', [100, 100, 2100, 1295]);
ha = tight_subplot(3,6,[.01 .03],[.1 .01],[.01 .01]);
for i = 1:numel(slices);
    im = volume(sq(1):sq(2),sq(3):sq(4),slices(i));
    im = im(:,:,[1 1 1]);
    seg2d = seg(sq(1):sq(2),sq(3):sq(4),slices(i));
    seg2d = seg2d(:,:,[1 1 1]);
    im = adjustContrast(im);
    filters = (seg2d == 1) .* red + (seg2d == 2) .* blue + (seg2d == 3) .* yellow + ...
        (seg2d == 4) .* green;
    out = im .* (1 - alpha) + filters .* alpha;    
    axes(ha(i)); subimage(out); set(gca,'XTickLabel',''); set(gca,'YTickLabel','');
end

saveas(fh, outfile);
%close all