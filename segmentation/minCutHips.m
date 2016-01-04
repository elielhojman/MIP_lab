function [ seg ] = minCutHips( mat, hipsSeg, side, conn )
%MINCUTHIPS Summary of this function goes here
%   Detailed explanation goes here

display('MinCutHips started');
if strcmp(side,'right') && strcmp(side,'left')
    error('FATAL - side must be "right" or "left"')
end

xMiddle = getXMiddle(hipsSeg);
hipsSide = zeros(size(hipsSeg));

if strcmp(side,'left')
    hipsSide(1:xMiddle,:,:) = hipsSeg(1:xMiddle,:,:); 
else
    hipsSide(xMiddle:end,:,:) = hipsSeg(xMiddle:end,:,:); 
end
intType = class(mat.img);
eval(['hipsSide = ' intType '(hipsSide);'])
hipsCT = mat.img .* hipsSide;

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
for i = 1:numel(nodesIdx)
    myIdx = nodesIdx(i);
    neigh = getNeighbours(hipsCT, myIdx, conn, 1);
    for j = 1:numel(neigh)
        neighIdx = neigh(j);
        if neighIdx > numel(nodeMap)  continue;  end;
        % The weight to put in the edge connection
        pixels = [hipsCT(neighIdx), hipsCT(myIdx)];        
        if min(pixels) <= 0 continue; end;
        Sx(k) = nodeMap(myIdx);
        Sy(k) = nodeMap(neighIdx);
        pixelsV(k,:) = pixels;        
        k = k + 1;
    end
end
display('Creating sparse matrix');
weights = min(pixelsV, [], 2).^2;        
%weights = mean(pixelsV, 2).^2;        
S = sparse(Sx,Sy,weights,nodesNum,nodesNum);

% Mark all of the nodes of the ilium
p = getIliumPoints(hipsSide, 'left');
iliumL = zeros(size(hipsSide));
iliumL(p) = 1;
iliumL = imdilate(iliumL, strel('square', 10));
iliumL = iliumL & hipsSide;

% Mark the sacrum points
[hipsStart, hipsEnd] = getStartEnd(hipsSide);
sacrum = zeros(size(hipsSide));
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
BK_Minimize(bk)
labeling = BK_GetLabeling(bk);

seg = zeros(size(hipsSide)); 
seg(nodesIdx(labeling == 2)) = 2;
seg(nodesIdx(labeling == 1)) = 1;
seg(iliumL) = 3;
seg(sacrum) = 4;

BK_Delete(BK_ListHandles())

end

