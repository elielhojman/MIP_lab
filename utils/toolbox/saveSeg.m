function [ output_args ] = saveSeg( matPath, seg, segName )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[basefolder, ~] = fileparts(matPath);
mat = load_untouch_nii_gzip(matPath);
outfileSeg = [basefolder,'/',segName];
for i = 1:size(seg,3)    
   % seg(:,:,i) = seg(:,:,i)';
    seg(:,:,i) = fliplr(seg(:,:,i));
end
matSeg = mat; matSeg.img = seg; save_untouch_nifti_gzip(matSeg, outfileSeg , 2);

end

