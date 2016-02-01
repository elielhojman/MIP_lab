function [ zoom ] = isHipsZoom( seg )
%ISHIPSZOOM Summary of this function goes here
%   Detailed explanation goes here

zoom = 0;
picWidth = size(seg,1);
picsWideWidth = 0;
for i = 1:size(seg,3)
    width = getWidth(seg(:,:,i));
    if width > 0.92 * picWidth
        picsWideWidth = picsWideWidth + 1;        
    end
end
if picsWideWidth > 1 && picsWideWidth < 0.7 * size(seg,3)
    zoom = 1;
end

end

function [ width ] = getWidth(X)
% Finds the width of the convhull
[x, y] = ind2sub(size(X), find(X));
if numel(x) == 0
    width = 0;
    return
end
idxs = convhull(x,y, 'simplify', true);
xh = x(idxs);
% yh = y(idxs);
width = max(xh) - min(xh);
end

