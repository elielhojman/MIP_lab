function [ seg ] = minCutHips( vol, hipsSeg, side, conn )
%MINCUTHIPS Summary of this function goes here
%   Detailed explanation goes here

display('MinCutHips started');
if strcmp(side,'right') && strcmp(side,'left')
    error('FATAL - side must be "right" or "left"')
end

xMiddle = getXMiddle(hipsSeg);
hipsSide = zeros(size(hipsSeg),'int8');

if strcmp(side,'left')
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
%for i = 1:numel(nodesIdx)
    myIdx = nodesIdx(i);
    neigh = getNeighbours(hipsCT, nodesIdx, conn, 1);

    neigh = neigh(neigh(:,1) <= numel(nodeMap),:);        
    % The weight to put in the edge connection
    pixels = [hipsCT(neigh(:,1)), hipsCT(neigh(:,2))];     
    neigh =  neigh(pixels(:,1) > 0,:);
    pixels = pixels(min(pixels,[],2) > 0,:); % Select only values above 0     
    Sx(k : k + size(neigh,1) -1 ) = nodeMap(neigh(:,2));
    Sy(k : k + size(neigh,1) -1 ) = nodeMap(neigh(:,1));
    pixelsV(k : k + size(neigh,1) -1 ,:) = pixels;
    k = k + size(neigh,1);

%end
display('Creating sparse matrix');
weights = min(pixelsV, [], 2).^2;        
%weights = mean(pixelsV, 2).^2;        
S = sparse(Sx,Sy,weights,nodesNum,nodesNum);

% Mark all of the nodes of the ilium
p = getIliumPoints(hipsSide, 'left');
iliumL = zeros(size(hipsSide),'int8');
iliumL(p) = 1;
iliumL = imdilate(iliumL, strel('square', 20));
iliumL = iliumL & hipsSide;

% Mark the sacrum points
[hipsStart, hipsEnd] = getStartEnd(hipsSide);
sacrum = zeros(size(hipsSide),'int8');
sacrum (xMiddle, :, hipsStart:hipsEnd) = 1;
% TODO, parametize this pixel value
sacrum = imdilate(sacrum, strel('square', 60));
sacrum = hipsSide & sacrum;

[sacrum, iliumL] = extendSacrumIlium(hipsSide, sacrum, iliumL, 'left');
% Load the unary matrix
U = zeros(2,nodesNum);
U(1,nodeMap(iliumL)) = 10e6;
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
seg(iliumL) = 3;
seg(sacrum) = 4;

BK_Delete(BK_ListHandles())

end

