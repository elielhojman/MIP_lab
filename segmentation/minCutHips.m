function [ seg ] = minCutHips( vol, info, hipsSeg, side, conn )
%MINCUTHIPS Summary of this function goes here
%   Detailed explanation goes here

pixelSize = info.DicomInfo.PixelSpacing(1);
hipsZoom = isHipsZoom(hipsSeg);

display('MinCutHips started');
if strcmp(side,'right') && strcmp(side,'left')
    error('FATAL - side must be "right" or "left"')
end

xMiddle = getXMiddle(hipsSeg);
hipsSide = zeros(size(hipsSeg),'int8');

if strcmp(side,'right')    
    hipsSide(1:xMiddle,:,:) = hipsSeg(1:xMiddle,:,:); 
else
    hipsSide(xMiddle:end,:,:) = hipsSeg(xMiddle:end,:,:); 
end
%intType = class(vol);
%eval(['hipsSide = ' intType '(hipsSide);'])
hipsCT = vol .* single(hipsSide);

nodesIdx = find(hipsSide);
maxIdx = max(nodesIdx);
nodeMap = zeros(1, maxIdx);
for i = 1:numel(nodesIdx)
    nodeMap(nodesIdx(i)) = i;
end

% Create the sparse matrix
nodesNum = numel(nodesIdx);
Sx = ones(1, nodesNum*conn/2,'double');
Sy = ones(1, nodesNum*conn/2,'double');
pixelsV = zeros(nodesNum*conn/2, 2,'double');
k = 1;

myIdx = nodesIdx(i);
neigh = getNeighbours(hipsCT, nodesIdx, conn, 1);

neigh = neigh(neigh(:,1) <= numel(nodeMap),:);        
% The weight to put in the edge connection
pixels = [hipsCT(neigh(:,1)), hipsCT(neigh(:,2))];     
neigh =  neigh(min(pixels,[],2) > 0,:);
pixels = pixels(min(pixels,[],2) > 0,:); % Select only values above 0     
Sx(k : k + size(neigh,1) -1 ) = nodeMap(neigh(:,2));
Sy(k : k + size(neigh,1) -1 ) = nodeMap(neigh(:,1));
pixelsV(k : k + size(neigh,1) -1 ,:) = pixels;
k = k + size(neigh,1);

% Increase the weight in the z axis
[row,col,~] = size(vol);
zPixels = neigh(:,1)-row*col == neigh(:,2);
pixelsV(zPixels) = pixelsV(zPixels)*2;
display('Creating sparse matrix');
weights = min(pixelsV, [], 2).^2;        
%weights = mean(pixelsV, 2).^2;        
S = sparse(Sx,Sy,weights,nodesNum,nodesNum);

% Mark all of the nodes of the ilium
display('Initialize ilium');
p = getIliumPoints(hipsSide, side);
ilium = zeros(size(hipsSide),'int8');
ilium(p) = 1;
if ~hipsZoom
    Rilium = round(25/pixelSize);
else
    Rilium = round(10/pixelSize);
end

ilium = imdilate(ilium, strel('square', Rilium));
ilium = ilium & hipsSide;

% Mark the sacrum points
display('Initialize sacrum');
[hipsStart, hipsEnd] = getStartEnd(hipsSide);
sacrum = zeros(size(hipsSide),'int8');
sacrum (xMiddle, :, hipsStart:hipsEnd) = 1;
% TODO, parametize this pixel value
CM_4 = round(40/pixelSize);
sacrum = imdilate(sacrum, strel('square', round(CM_4/3)));
sacrum = hipsSide & sacrum;
sacrum = imdilate(sacrum, strel('square', round(CM_4/3)));
sacrum = hipsSide & sacrum;
sacrum = imdilate(sacrum, strel('square', round(CM_4/3)));
sacrum = hipsSide & sacrum;

[sacrum, ilium] = extendSacrumIlium(hipsSide, sacrum, ilium, side);
% Load the unary matrix
U = zeros(2,nodesNum);
U(1,nodeMap(ilium)) = 10e6;
U(2,nodeMap(sacrum)) = 10e6;

bk = BK_Create(nodesNum, nodesNum*conn/2);
BK_SetNeighbors(bk, S);
BK_SetUnary(bk, U);
display('Finding min-cut');
BK_Minimize(bk)
labeling = BK_GetLabeling(bk);

seg = zeros(size(hipsSide),'int8'); 
seg(nodesIdx(labeling == 2)) = 2;
seg(nodesIdx(labeling == 1)) = 1;
seg(ilium) = 3;
seg(sacrum) = 4;

BK_Delete(BK_ListHandles())

end

