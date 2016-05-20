accNum = '4015006263625';
folderPath = 'sacro/dataset/';
matFile = [folderPath accNum  '/' accNum '.mat'];
segFile = [folderPath accNum  '/' 'segBorder.mat'];

load(matFile);
load(segFile);
vol = dicom2niftiVol(vol,dicomInfo);
% Load segmentation
imgs = getImagesFromBorderSeg( segBorder, vol, dicomInfo.Scales(1:2), [8 8], [32 32] );