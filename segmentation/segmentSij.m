function [ seg, noise ] = segmentSij( fPath, outfile  )
%SEGMENTSIJ Run segmentation on the SacroIlium Joint
% We need to point the folder containing the DICOM files.
% Optional
%  - boolean outfile: 
%        Specify if we want to generate a jpg image with the output results
[basefolder, folder] = fileparts(fPath);
dicomInfo = dicom_folder_info(fPath);
vol = dicom_read_volume(fPath);
slices = size(vol,3); display(slices);
vol = dicom2niftiVol(vol, dicomInfo);
bonesSeg = getBones(vol, 0);
hipsSeg = getHips(bonesSeg, 0, vol); clearvars bonesSeg;
seg = minCutHips(vol, hipsSeg, 'left', 10);
if exist('outfile','var')
    close all;
    picsSeries(seg, vol, [basefolder, '/', folder, '.jpg']);
end
noise = getNoiseValue(vol);
end

