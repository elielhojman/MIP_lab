function [ xMiddle ] = getXMiddle( hipsSeg )
%GETXMIDDLE Find the middle point in the x axis of the hips
% We go over all of the axial images and find the middle point of the
% convhull. We then average all of the results found.
[hSt, hEnd] = getStartEnd(hipsSeg);
xMiddles = [];
for i = hSt:hEnd
    square = getConvhullSquare(hipsSeg(:,:,i));
    xMiddles(end + 1) = (square(2) + square(1))/2;
end
xMiddle = round(mean(xMiddles));

