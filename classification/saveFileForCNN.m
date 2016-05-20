function [ output_args ] = saveFileForCNN( imgs, labels, fileImgs, fileLabels )
%SAVEFILEFORCNN Summary of this function goes here
%   Detailed explanation goes here
[rows, cols, totalImgs] = size(imgs);
X = zeros([ rows cols 1 totalImgs],'uint16');
Y = zeros(2,totalImgs,'uint8');

if max(labels(:)) > 2 || min(labels(:)) < 1
    error('labels must be between 1 or 2');
end

for i = 1:size(imgs,3)
    X(:,:,1,i) = imgs(:,:,i);
    if isscalar(labels)
        Y(labels,i) = 1;
    else
        Y(labels(i),i) = 1;
    end    
end

fid = fopen(fileImgs,'wb'); fwrite(fid,X(:),'uint16'); fclose(fid);
fid = fopen(fileLabels,'wb'); fwrite(fid,Y(:),'uint8'); fclose(fid);

end

