
% We get the CT only of the hips segmented area
xMiddle = 265;
hipsLeft = zeros(size(hipsSeg));

% We first do the min cut of the left part
hipsLeft(1:xMiddle,:,:) = hipsSeg(1:xMiddle,:,:); 
intType = class(matpat.img);
eval(['hipsLeft = ' intType '(hipsLeft);'])
hipsCT = matpat.img .* hipsLeft;

% Node map. We map the idx of the node in the image to 1,2,3 ...
nodesIdx = find(hipsLeft);
maxIdx = max(nodesIdx);
nodeMap = zeros(1, maxIdx);
for i = 1:numel(nodesIdx)
    nodeMap(nodesIdx(i)) = i;
end

% Create the sparse matrix
conn = 10;
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
%         if myIdx + cols == neighIdx
%             pixels = pixels ./100;
%         end
%         if myIdx + 1 == neighIdx
%             pixels = pixels ./100;
%         end
        if myIdx + cols*rows == neighIdx
            pixels = pixels * 4;
        end
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
p = getIliumPoints(hipsSeg, 'left');
iliumL = zeros(size(hipsSeg));
iliumL(p) = 1;
iliumL = imdilate(iliumL, strel('square', 10));
iliumL = iliumL & hipsSeg;

% Mark the sacrum points
sacrum = zeros(size(hipsSeg));
sacrum (xMiddle, :, hipsStart:hipsEnd) = 1;
% TODO, move to cm instead of pixels
sacrum = imdilate(sacrum, strel('square', 70));
sacrum = hipsLeft & sacrum;

[sacrum, iliumL] = extendSacrumIlium(hipsLeft, sacrum, iliumL, 'left');

% Load the unary matrix
U = zeros(2,nodesNum);
U(1,nodeMap(iliumL)) = 10e6;
U(2,nodeMap(sacrum)) = 10e6;

bk = BK_Create(nodesNum, nodesNum*conn/2);
BK_SetNeighbors(bk, S);
BK_SetUnary(bk, U);
BK_Minimize(bk)
labeling = BK_GetLabeling(bk);

seg = zeros(size(hipsSeg)); 
seg(nodesIdx(labeling == 2)) = 2;
seg(nodesIdx(labeling == 1)) = 1;
seg(iliumL) = 3;
seg(sacrum) = 4;

matSeg = matpat; matSeg.img = seg; save_untouch_nifti_gzip(matSeg, 'sacro/pat/minCut.nii', 2)

BK_Delete(BK_ListHandles())


        