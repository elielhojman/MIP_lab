function [ segL, score, noise ] = segmentSij( fPath, outfile  )
%SEGMENTSIJ Run segmentation on the SacroIlium Joint
% We need to point the folder containing the DICOM files.
% Optional
%  - boolean outfile: 
%        Specify if we want to generate a jpg image with the output results
[basefolder, folder] = fileparts(fPath);
if exist([fPath,'/',folder,'.mat'],'file')
    load([fPath,'/',folder,'.mat'])
else
    dicomInfo = dicom_folder_info(fPath);
    vol = dicom_read_volume(fPath);
end
slices = size(vol,3); display(slices);
vol = dicom2niftiVol(vol, dicomInfo);
bonesSeg = getBones(vol, 0);
hipsSeg = getHips(bonesSeg, 0, vol); clearvars bonesSeg;
segR = minCutHips(vol, dicomInfo, hipsSeg, 'right', 10);
segL = minCutHips(vol, dicomInfo, hipsSeg, 'left', 10);
if exist('outfile','var')
    close all;
    picsSeries(segR, vol, [basefolder, '/', folder, '_R4.jpg']);
    picsSeries(segL, vol, [basefolder, '/', folder, '_L4.jpg']);
end
scoreL = scoreSegmentation(segL,vol,dicomInfo,'left');
scoreR = scoreSegmentation(segR,vol,dicomInfo,'right');
score = [scoreL;scoreR];
noise = getNoiseValue(vol);
end

