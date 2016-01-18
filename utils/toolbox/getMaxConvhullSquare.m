function [ square ] = getMaxConvhullSquare( seg, startS, endS )
%GETMAXCONVHULLSQUARE Returns the slice and square with the largest convhull
maxX = -Inf; minX = Inf;
maxY = -Inf; minY = Inf;
for s = startS:endS
    sq = getConvhullSquare(seg(:,:,s));
    if sq(1) < minX;   minX = sq(1);     end
    if sq(2) > maxX;   maxX = sq(2);     end
    if sq(3) < minY;   minY = sq(3);     end
    if sq(4) > maxY;   maxY = sq(4);     end
end
square = [minX maxX minY maxY];

end

