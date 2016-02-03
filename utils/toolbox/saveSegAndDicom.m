function saveSegAndDicom( fPath, seg)
%SAVESEGANDDICOM Summary of this function goes here
[basefolder, folder] = fileparts(fPath);
outfile = ['sacro/', folder];
dicm2nii(fPath, outfile,'nii.gz');
files = dir(outfile);
for i = 1:length(files);
    display(files(i).name)
    if regexp(files(i).name,'nii.gz') > 0;
        file = files(i).name;
    end
end

for i=1:size(seg,3)
    seg(:,:,i) = fliplr(seg(:,:,i));
end
mat = load_untouch_nii_gzip([outfile,'/',file]);
outfileSeg = [outfile,'/','seg'];
matSeg = mat; matSeg.img = seg; save_untouch_nifti_gzip(matSeg, outfileSeg , 2);
end

