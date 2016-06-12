%% Save train file
trainFile = 'C:\Users\elielhs\Dropbox\Universidad\MIP report\data\train.images.small.bin';
labelsFile = 'C:\Users\elielhs\Dropbox\Universidad\MIP report\data\train.labels.bin';

%%
folderPathP = 'images/imgs_uint_P_resize/';
folderPathN = 'images/imgs_uint_N_resize/';
fileslistP = dir([folderPathP '*.png']);
fileslistN = dir([folderPathN '*.png']);
fileslists = {fileslistP; fileslistN};
folderpaths = {folderPathP; folderPathN};
group = [];
traindata = [];
normalize = 0;
totalfiles = numel(fileslistP) + numel(fileslistN);
j = 1;
for k = 1:numel(fileslists)
    fileslist = fileslists{k};
    folderPath = folderpaths{k};
    for i = 1:size(fileslist,1)       
        Y(k+1,j) = 1;       
        imdata = imread([folderPath, fileslist(i).name]);
        X(:,:,1,j) = imdata;
        clearvars imdata2
        j = j + 1;
    end
end


%% Save 
fid = fopen(trainFile,'wb'); fwrite(fid,X(:),'uint8'); fclose(fid);

fid = fopen(labelsFile,'wb'); fwrite(fid,Y(:),'uint8'); fclose(fid);

% Then, create trainImages by
%   fid = fopen(trainImages,'wb'); fwrite(fid,X(:),'uint8'); fclose(fid);
% To create the label file, suppose we have k classes and let Y be a matrix
% with Y(:,i) being all zeros vector except 1 in the position j, where j is
% the correct label of example i. Then, create trainLabels by:
%   fid = fopen(trainLabels,'wb'); fwrite(fid,Y(:),'uint8'); fclose(fid);

