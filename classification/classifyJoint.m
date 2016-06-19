function [ label ] = classifyJoint( imgMatFile, threshold, imgPerc )
%CLASSIFYJOINT Summary of this function goes here
%   Detailed explanation goes here
load(imgMatFile);
idxs = (score(:,1) < (score(:,2) - threshold));
labelIdx(~idxs) = 1;
if mean(labelIdx == 2)*100 < imgPerc
    label = 1;
else
    label = 2;
end

end

