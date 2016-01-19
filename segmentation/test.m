basefolder = 'sacro/dataset/';
for i = 1:numel(data)
    if exist([basefolder, data{i}.accessNum],'file') 
        if isfield(data{i}, 'noise')
            continue;
        end
        filename = [basefolder, data{i}.accessNum];
        display(filename);        
        [seg, noise] = segmentSij(filename, 1);
        data{i}.noise = noise;        
    end
end
