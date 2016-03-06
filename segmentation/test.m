basefolder = 'sacro/dataset/';
for i = 1:numel(data)
    fPath = [basefolder, data{i}.accessNum];
    if exist(fPath,'file') 
        display(fPath);

%         if isfield(data{i}, 'noise')
%             continue;
%         end
        filename = [basefolder, data{i}.accessNum];               
        tic; [seg, score, noise] = segmentSij(filename); toc;
        data{i}.noise = noise;        
        data{i}.score = score;
        info = data{i};
        segFile = [fPath '/segmentation'];
        save(segFile, 'seg', 'info');
    end
end
