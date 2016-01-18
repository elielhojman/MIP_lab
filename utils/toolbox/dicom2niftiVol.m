function [ vol ] = dicom2niftiVol( dicom_vol, dicom_info )
%DICOM2NIFTIVOL A simple transformation to get the DICOM result in the nifti volume style
if ~isfield(dicom_info, 'DicomInfo')
    error('No DicomInfo was found in the struct');
end

if ~isfield(dicom_info.DicomInfo,'RescaleIntercept') || ...
        ~isfield(dicom_info.DicomInfo, 'RescaleSlope')
    error('Slope/Intercept rescale was not found in the dicom info');
end

vol = zeros(size(dicom_vol));
% This is related to the orientation, which may change between images
for i = 1:size(dicom_vol,3)
    vol(:,:,i) = dicom_vol(:,:,end-i+1)';
end

vol = vol * dicom_info.DicomInfo.RescaleSlope + ...
        dicom_info.DicomInfo.RescaleIntercept;
end

