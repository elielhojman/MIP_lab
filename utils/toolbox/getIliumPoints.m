function [ points ] = getIliumPoints( hipsSeg, hipsStart, hipsEnd, side )
%GETILIUMPOINTS Summary of this function goes here
%   Detailed explanation goes here

centerZ = round( (hipsStart + hipsEnd) / 2);
square = getConvhullSquare(hipsSeg(:,:,centerZ));

[rows,cols,~] = size(hipsSeg);
points = [];
if strcmp(side, 'left')
    centerX = (square(1) + square(2)) / 2;
    leftSide = square(1) + abs(square(1) - centerX) / 3;
    for i = hipsStart:hipsEnd
        for j = 1:cols
            p = find(hipsSeg(:, j, i),1,'first');
            if size(p,1) > 0 && p < leftSide             
                points(end+1) = rows*cols*(i-1) + rows*(j-1) + p;
            end
        end
    end
end


