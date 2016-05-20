function [ ] = saveByAccNum( accNum )

if accNum(end) == 'L' || accNum(end) == 'R'
    accNum = accNum(1:end-1);
end

load(['sacro/dataset/' accNum,'/segmentationNoCanny.mat']);
saveSegAndDicom(['sacro/dataset/', accNum],seg,'segmentation');

end

