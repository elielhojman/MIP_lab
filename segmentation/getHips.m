function [ hipsSeg ] = getHips( bonesSeg, fill, volume )
%GETHIPS Get the area of the binary pixels of the hips
%   We search for the change in the convhull to find the spine.
%   To find the start of the hips we search for the end of the spine
%   If we add the volume this means that we recalculate the bones of the
%   hips using the imin and imax defined below.

topSlice = size(bonesSeg,3);
zoom = isHipsZoom(bonesSeg);
convhullWidth = [];
Rconv = 0.3;
if zoom
    Rconv = 0.6;
end
for j = 10:10:topSlice;    
    convhullWidth(end+1) = getWidth(bonesSeg(:,:,j));
    % Last value much smaller than max, we started the spine
    if convhullWidth(end) < max(convhullWidth)*Rconv;
        hipsEnd = j - 10;
        spineStart = j;
        break;
    end
end

if ~exist('hipsEnd','var')
    hipsEnd = topSlice-10;
    spineStart = topSlice;
end

if ~exist('hipsEnd','var')
    display('FATAL - Start of spine could not be found');
    return;
end

% Search for end of spine
square = getConvhullSquare(bonesSeg(:,:,spineStart));
if square(1) == 0 || square(2) == 0
    square = [1 size(bonesSeg,1) 1 size(bonesSeg,2)];
end
lowerSpine = zeros(size(bonesSeg),'int8');
% As we care about the sacro-ilium join we can look until the end of the
% spine the y axis as well
lowerSpine(square(1):square(2), :, 1:spineStart) = 1;
yMinSpine = square(3);

spinePixels = [];
for j = hipsEnd:-1:1;
    spineImg = lowerSpine(:,:,j) & bonesSeg(:,:,j);
    spinePixels(end+1) = numel(find(spineImg));
    if spinePixels(end) < 30
        hipsStart = j;
        break;
    end
end

if ~exist('hipsStart','var')
    [~,j] = min(spinePixels);
    hipsStart = hipsEnd - j + 1;
end
    
if ~exist('hipsStart','var')
    display('FATAL - End of spine could not be found');
    return;
end

if zoom
    hipsStart = 1;
end

display(hipsStart);
display(hipsEnd);

hipsArea = zeros(size(bonesSeg),'int8');
hipsArea(:,yMinSpine:end ,hipsStart:hipsEnd) = 1;

if ~exist('volume','var')    
    hipsSeg = bonesSeg & hipsArea;    
else
    imax = 1300;
    imin = 200;    
    volume = single(hipsArea) .* volume;
    hipsSeg = (volume < imax) & (volume > imin);
    
    % Add canny edge
    display('Calculating canny edge');
    edgesHips = canny(volume(:,:,hipsStart:hipsEnd),[1 1 0], 'TMethod','relMax', 'TValue',[0.03, 0.9]);
    edges = zeros(size(hipsSeg),'int8');
    edges(:,:,hipsStart:hipsEnd) = int8(edgesHips); clear edgesHips;
    edges = edges & (volume > 50) & volume <= imin;        
    hipsSeg = hipsSeg | edges; clearvars edges;
    
    CC = bwconncomp(hipsSeg, 26);
    numPixels = cellfun(@numel, CC.PixelIdxList);
    [~,maxIdx] = max(numPixels);
    hipsSeg = zeros(size(volume),'int8');
    hipsSeg(CC.PixelIdxList{maxIdx}) = 1; 
    if fill
        hipsSeg = fillHoles(hipsSeg,1);
    end
end
end


function [ width ] = getWidth(X)
% Finds the width of the convhull
[x, y] = ind2sub(size(X), find(X));
if numel(x) == 0
    width = 0;
    return
end
idxs = convhull(x,y, 'simplify', true);
xh = x(idxs);
% yh = y(idxs);
width = max(xh) - min(xh);
end


