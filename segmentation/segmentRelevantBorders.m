function [ seg ] = segmentRelevantBorders( originalSeg, pixelSz, pixelZSz )
%SEGMENTRELEVANTAREA Summary of this function goes here
%   Detailed explanation goes here

iliumR = segmentRelevantBorder(originalSeg, 'R', 'ilium', pixelSz, pixelZSz);
iliumL = segmentRelevantBorder(originalSeg, 'L', 'ilium', pixelSz, pixelZSz);
sacrumR = segmentRelevantBorder(originalSeg, 'R', 'sacrum', pixelSz, pixelZSz);
sacrumL = segmentRelevantBorder(originalSeg, 'L', 'sacrum', pixelSz, pixelZSz);

% Ilium is 2, sacrum is 1
seg.L = (iliumL) .* 2 + sacrumL;
seg.R = iliumR .* 2 + sacrumR; 

end

