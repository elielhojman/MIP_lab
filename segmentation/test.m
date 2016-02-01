basefolder = 'sacro/dataset/';
for i = 1:numel(data)
    fPath = [basefolder, data{i}.accessNum];
    if exist(fPath,'file') 
        display(fPath);

%         if isfield(data{i}, 'noise')
%             continue;
%         end
        filename = [basefolder, data{i}.accessNum];               
        tic; [seg, sc, noise] = segmentSij(filename, 1); toc;
        data{i}.noise = noise;        
        data{i}.score = sc;
    end
end
