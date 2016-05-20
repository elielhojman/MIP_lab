function [ seg ] = segmentRelevantBorders( originalSeg, pixelSz )
%SEGMENTRELEVANTAREA Summary of this function goes here
%   Detailed explanation goes here

iliumR = segmentRelevantBorder(originalSeg, 'R', 'ilium', pixelSz);
iliumL = segmentRelevantBorder(originalSeg, 'L', 'ilium', pixelSz);
sacrumR = segmentRelevantBorder(originalSeg, 'R', 'sacrum', pixelSz);
sacrumL = segmentRelevantBorder(originalSeg, 'L', 'sacrum', pixelSz);

% Ilium is 2, sacrum is 1
seg.L = (iliumL) .* 2 + sacrumL;
seg.R = iliumR .* 2 + sacrumR; 

end

