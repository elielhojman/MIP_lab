function [ square ] = getConvhullSquare(X)
%GETCONVHULLSQUARE Finds the square containing the convhull in 2D
%   INPUT
%     X - 2D matrix
%   OUTPUT
%     square - [xmin xmax ymin ymax]

% Finds the width of the convhull
if max(X(:)) == 0
    square = [0, 0, 0, 0];
    return
end
[x, y] = ind2sub(size(X), find(X));
idxs = convhull(x,y, 'simplify', true);
xh = x(idxs);
yh = y(idxs);
square = [min(xh) max(xh) min(yh) max(yh)];
end


