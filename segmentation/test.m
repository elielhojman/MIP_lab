mat = load_untouch_nii('sacro/normal/093.nii');
bonesSeg = getBones(mat.img, 0);
hipsSeg = getHips(bonesSeg, 0, mat.img);
seg = minCutHips(mat, hipsSeg, 'left', 10);

matSeg = mat; matSeg.img = seg; save_untouch_nifti_gzip(matSeg, 'sacro/normal/minCut093.nii', 2)