function [ seg, noise ] = segmentSij( fPath, outfile  )
%SEGMENTSIJ Run segmentation on the SacroIlium Joint
% We need to point the folder containing the DICOM files.
% Optional
%  - boolean outfile: 
%        Specify if we want to generate a jpg image with the output results
[basefolder, folder] = fileparts(fPath);
dicomInfo = dicom_folder_info(fPath);
dicomVol = dicom_read_volume(fPath);
slices = size(dicomVol,3); display(slices);
vol = dicom2niftiVol(dicomVol, dicomInfo);
bonesSeg = getBones(vol, 0);
hipsSeg = getHips(bonesSeg, 0, vol);
seg = minCutHips(vol, hipsSeg, 'left', 10);
if exist('outfile','var')
    picsSeries(seg, vol, [basefolder, '/', folder, '.jpg']);
end
noise = getNoiseValue(vol);
end

