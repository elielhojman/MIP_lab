basefolder = 'sacro/dataset/';
for i = 1:numel(dataWithCanny)
    fPath = [basefolder, dataWithCanny{i}.accessNum];
    segFile = [fPath '/segmentationWithCanny.mat'];
    if exist(fPath,'file') 
        display(fPath);

        if exist(segFile,'file') > 0
            display('Already segmented');
            continue;
        end
        filename = [basefolder, dataWithCanny{i}.accessNum];               
        tic; [seg, score, noise] = segmentSij(filename,'withCanny'); toc;
        dataWithCanny{i}.noise = noise;        
        dataWithCanny{i}.score = score;
        info = dataWithCanny{i};
        segFile = [fPath '/segmentationWithCanny'];
        save(segFile, 'seg', 'info');
    end
end
