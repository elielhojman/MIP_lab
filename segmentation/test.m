basefolder = 'sacro/dataset/';
for i = 1:numel(data)
    fPath = [basefolder, data{i}.accessNum];
    if exist(fPath,'file') 
        display(fPath);
        dicomInfo = dicom_folder_info(fPath);
        vol = dicom_read_volume(fPath);                
        save([fPath, '/', data{i}.accessNum], 'vol','dicomInfo');
%         if isfield(data{i}, 'noise')
%             continue;
%         end
%         filename = [basefolder, data{i}.accessNum];
%         display(filename);        
%         tic; [seg, noise] = segmentSij(filename, 1); toc;
%         data{i}.noise = noise;        
    end
end
