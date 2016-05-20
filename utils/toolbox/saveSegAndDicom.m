function saveSegAndDicom( fPath, seg, segName)
%SAVESEGANDDICOM Summary of this function goes here
[basefolder, folder] = fileparts(fPath);
outfile = ['sacro/', folder];
display(outfile);
dicm2nii(fPath, outfile,'nii.gz');
files = dir(outfile);
pause(10);
for i = 1:length(files);
    display(files(i).name)
    if regexp(files(i).name,'nii.gz') > 0;
        file = files(i).name;
    end
end

if isstruct(seg)
    seg = seg.L + seg.R;
end

for i=1:size(seg,3)
    seg(:,:,i) = fliplr(seg(:,:,i));
end
pause(20);
pause(10);
mat = load_untouch_nii_gzip([outfile,'/',file]);
outfileSeg = [outfile,'/',segName];
matSeg = mat; matSeg.img = seg; save_untouch_nifti_gzip(matSeg, outfileSeg , 2);
end

