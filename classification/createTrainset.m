load pointsOfInterestFull.mat
%%
imgMmSz = [14 14];
imgPixlSz = round(imgMmSz/0.25);
imgs0 = getImageFromPoint(diag0Points,imgMmSz, imgPixlSz);
imgs0sh = getImageFromPoint(diag0Points,imgMmSz, imgPixlSz, 6);
% imgs01sh = getImageFromPoint(diag0Points,imgMmSz, imgPixlSz, 6);
% imgs02sh = getImageFromPoint(diag0Points,imgMmSz, imgPixlSz, 6);
% imgs03sh = getImageFromPoint(diag0Points,imgMmSz, imgPixlSz, 6);
disp('diag1 Points');
imgs1 = getImageFromPoint(diag1Points,imgMmSz, imgPixlSz);
imgs1sh = getImageFromPoint(diag1Points,imgMmSz, imgPixlSz, 6);
% imgs12 = getImageFromPoint(diag1Points,imgMmSz, imgPixlSz, 6);
disp('diag2 Points');
imgs2 = getImageFromPoint(diag2Points,imgMmSz, imgPixlSz);
imgs2sh = getImageFromPoint(diag2Points,imgMmSz, imgPixlSz,6);
% imgs22 = getImageFromPoint(diag2Points,imgMmSz, imgPixlSz,6);
disp('diag3 Points');
imgs3 = getImageFromPoint(diag3Points,imgMmSz, imgPixlSz);
imgs3sh = getImageFromPoint(diag3Points,imgMmSz, imgPixlSz,6);

%%
imgPixlSz = [36 36];
imgs = {imgs0; imgs0sh; imgs1; imgs1sh; imgs2; imgs2sh; imgs3; imgs3sh};
labelsIdx = [1 1 2 2 2 2 2 2];
totalImgs = 0;
for i = 1:numel(imgs)
    totalImgs = totalImgs + size(imgs{i},3);
end
X = zeros([imgPixlSz 1 totalImgs],'uint8');
Y = zeros(2,totalImgs,'uint8');

j = 1;
for i = 1:numel(imgs)    
    myImgs = imgs{i};
    disp(i)
    for k = 1:size(myImgs,3)
        %disp(k);
        myImg = myImgs(:,:,k);
        myImg = (myImg > 0) .* myImg;
        X(:,:,1,j) = myImg./max(myImg(:)) .* 255;
        Y(labelsIdx(i),j) = 1;        
        j = j + 1;
    end
end

%% Save all images
diagnosis = [ 0 0 1 1 2 2 3 3];
removeall = 0;
folderPath = ['images/allImgs'];
mkdir(folderPath);
for i = 1:numel(imgs);   
    if removeall
        rmdir(folderPath);
        display(['Removed ' folderPath]);
        continue;
    end    
    
    myImgs = imgs{i};
    if diagnosis(i) == 0
        label = 'N';
    else
        label = 'P';
    end
    for j = 1:size(myImgs,3);
        myImg = myImgs(:,:,j);
        myImg = (myImg > 0) .* myImg;
        myImg = myImg./max(myImg(:)) .* 255;
        imwrite(myImg, [folderPath '/img' num2str(i) '_' num2str(j) '_' label '.jpg']);
    end
end

%% Save train file
trainFile = 'train.images.small.bin';
labelsFile = 'train.labels.bin';
fid = fopen(trainFile,'wb'); fwrite(fid,X(:),'uint8'); fclose(fid);
%% Save labels
fid = fopen(labelsFile,'wb'); fwrite(fid,Y(:),'uint8'); fclose(fid);

% Then, create trainImages by
%   fid = fopen(trainImages,'wb'); fwrite(fid,X(:),'uint8'); fclose(fid);
% To create the label file, suppose we have k classes and let Y be a matrix
% with Y(:,i) being all zeros vector except 1 in the position j, where j is
% the correct label of example i. Then, create trainLabels by:
%   fid = fopen(trainLabels,'wb'); fwrite(fid,Y(:),'uint8'); fclose(fid);
