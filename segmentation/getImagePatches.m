imgMmSz = [14 14];
for i = 1:numel(data)
    d = data{i};  
    if strcmp(d.accessNum,'4015005343997')
        disp('skip');
        continue;
    end
    segborderfile = ['sacro/dataset/', d.accessNum, '/segBorder.mat'];
    volfile = ['sacro/dataset/', d.accessNum, '/',d.accessNum,'.mat'];
    if exist(segborderfile,'file') && exist(volfile,'file')
        segR = [d.accessNum, 'R'];
        segL = [d.accessNum, 'L'];        
        if exist(['images/dataset/',segR],'file') || exist(['images/dataset/',segL],'file')
            disp('skipping');
            continue;
        end
        if ~sum(strcmp(segR,goodAll)) && ~sum(strcmp(segL,goodAll))
            disp('skipping');
            continue;
        end
        
        load(volfile);
        load(segborderfile);
        vol = dicom2niftiVol(vol, dicomInfo);
        pixelSz = [dicomInfo.Scales(1) dicomInfo.Scales(3)];
        disp(pixelSz);
        
        if sum(strcmp(segR,goodAll))
            disp(['Acquiring images for ' segR,'. Slices: ', num2str(size(vol,3))]);
            imgs = getImagesFromBorderSeg(segBorder.R, vol, pixelSz, imgMmSz, imgMmSz*4,'R');
            saveImages(['images/dataset/',segR],imgs.sacrum,'sac');
            saveImages(['images/dataset/',segR],imgs.ilium,'il');
        end
        
        if sum(strcmp(segL,goodAll))
            disp(['Acquiring images for ' segL,'. Slices: ', num2str(size(vol,3))]);            
            imgs = getImagesFromBorderSeg(segBorder.L, vol, pixelSz, imgMmSz, imgMmSz*4,'L');
            saveImages(['images/dataset/',segL],imgs.sacrum,'sac');
            saveImages(['images/dataset/',segL],imgs.ilium,'il');
        end
    end
end
