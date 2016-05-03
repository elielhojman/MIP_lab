segFile = 'segmentationNoCanny.mat';
pathPrefix = 'sacro/dataset/';
a = dir(pathPrefix);
content = dir(pathPrefix);
data = {};
for i = 1:numel(content);
    fileName = strcat(pathPrefix, a(i).name, '/',segFile);
    if exist(fileName,'file')
        disp(fileName);
        load(fileName);
        data{end+1} = info;
    end
end


        