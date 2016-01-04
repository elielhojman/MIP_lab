function [ hipsSeg ] = getHips( bonesSeg, fill, volume )
%GETHIPS Get the area of the binary pixels of the hips
%   We search for the change in the convhull to find the spine.
%   To find the start of the hips we search for the end of the spine
%   If we add the volume this means that we recalculate the bones of the
%   hips using the imin and imax defined below.

topSlice = size(bonesSeg,3);
convhullWidth = [];
for j = 10:10:topSlice;    
    convhullWidth(end+1) = getWidth(bonesSeg(:,:,j));
    % Last value much smaller than max, we started the spine
    if convhullWidth(end) < max(convhullWidth)*0.3
        hipsEnd = j - 10;
        spineStart = j;
        break;
    end
end

if ~exist('hipsEnd','var') && topSlice > 150
    hipsEnd = topSlice;
end

if ~exist('hipsEnd','var')
    display('FATAL - Start of spine could not be found');
    return;
end

% Search for end of spine
square = getConvhullSquare(bonesSeg(:,:,spineStart));
lowerSpine = zeros(size(bonesSeg));
% As we care about the sacro-ilium join we can look until the end of the
% spine the y axis as well
lowerSpine(square(1):square(2), :, 1:spineStart) = 1;
yMinSpine = square(3);

for j = hipsEnd:-1:1;
    spineImg = lowerSpine(:,:,j) & bonesSeg(:,:,j);
    spinePixels = numel(find(spineImg));
    if spinePixels < 60
        hipsStart = j;
        break;
    end
end

if ~exist('hipsStart','var') && topSlice < 130
    hipsStart = 1;
end
    
if ~exist('hipsStart','var')
    display('FATAL - End of spine could not be found');
    return;
end

display(hipsStart);
display(hipsEnd);

hipsArea = zeros(size(bonesSeg));
hipsArea(:,yMinSpine:end ,hipsStart:hipsEnd) = 1;

if ~exist('volume','var')    
    hipsSeg = bonesSeg & hipsArea;    
else
    imax = 1300;
    imin = 210;
    intType = class(volume);
    eval(['hipsArea = ' intType '(hipsArea);'])
    volume = hipsArea .* volume;
    hipsSeg = (volume < imax) & (volume > imin);
    CC = bwconncomp(hipsSeg, 26);
    numPixels = cellfun(@numel, CC.PixelIdxList);
    [~,maxIdx] = max(numPixels);
    hipsSeg = zeros(size(volume));
    hipsSeg(CC.PixelIdxList{maxIdx}) = 1; 
    if fill
        hipsSeg = fillHoles(hipsSeg,1);
    end
end
end


function [ width ] = getWidth(X)
% Finds the width of the convhull
[x, y] = ind2sub(size(X), find(X));
idxs = convhull(x,y, 'simplify', true);
xh = x(idxs);
% yh = y(idxs);
width = max(xh) - min(xh);
end


