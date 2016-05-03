function [ boundary ] = getOuterBorder( side, seg, boneType )
%GETOUTERBORDER Summary of this function goes here
%   boneType is sacrum or ilium
if ~strcmp(boneType,'sacrum') && ~strcmp(boneType,'ilium')
    error('boneType must be "sacrum" or "ilium"');
end

if isstruct(seg)
    if strcmp(side, 'R')
        seg = seg.R;
    elseif strcmp(side, 'L')
        seg = seg.L;
    else
        error('Select side "L" or "R"');
    end
end

sacrum = seg == 4 | seg == 1;
ilium = seg == 2 | seg == 3;

if strcmp(side,'R')
    if strcmp(boneType,'sacrum')
        boundary = getBoundary(sacrum,'R');
    else
        boundary = getBoundary(ilium,'L');
    end
else
    if strcmp(boneType,'sacrum')
        boundary = getBoundary(sacrum,'L');
    else
        boundary = getBoundary(ilium,'R');
    end
end
end


function [boundary] = getBoundary(seg, side)
    boundary = zeros(size(seg));
    idxs = [];
    [rows,cols,~] = size(seg);    
    for i = 1:size(seg,3)
        plane = seg(:,:,i)';
        plane = fliplr(plane);
        for j = 1:rows;
            row = plane(j,:);
            idxRow = 0;
            if side == 'L'
                idxRow = find(row,1,'first');
            else % last
                idxRow = find(row,1,'last');
            end
            if idxRow                
                idxs(end+1) = (i-1)*(rows*cols) + (idxRow-1)*cols + j;
            end            
        end
    end
    boundary(idxs) = 1;
end
                    