function [  sacrum, ilium ] = extendSacrumIlium( hipsSeg, sacrum, ilium, side )
%EXTENDSACRUMILIUM Extend the identification of points for scarum and ilium
%   We go over the axial pictures and for full components that do not have
%   any points which belong both to ilium and sacrum we extend them to
%   belong to only one of them. 
% INPUTS
%  - hipsSeg, hips segmentation
%  - sacrum, points previously defined as belonging to the sacrum
%  - ilium, points previously defined as belonging to the ilium
  
[hipsStart, hipsEnd] = getStartEnd(hipsSeg);
[rows,cols,~] = size(hipsSeg);
extendStart = hipsStart + round ( (hipsEnd-hipsStart)/ 2);
for i = extendStart:hipsEnd
    sacP = find(sacrum(:,:,i));
    iliP = find(ilium(:,:,i));
    CC = bwconncomp(hipsSeg(:,:,i));
    isSacMemb = @(P) max(ismember(P,sacP));
    isIliMemb = @(P) max(ismember(P,iliP));
    sacMembers = cellfun(isSacMemb,CC.PixelIdxList);
    iliMembers = cellfun(isIliMemb,CC.PixelIdxList);
    sacOnlyMembers = sacMembers & ~iliMembers;    
    iliOnlyMembers = iliMembers & ~sacMembers;
    for j = find(sacOnlyMembers)
        if j == 0; continue; end;
        sac3dP = rows*cols*(i-1) + CC.PixelIdxList{j};
        sacrum(sac3dP) = 1;
    end
    for j = find(iliOnlyMembers)
        if j == 0; continue; end;
        ili3dP = rows*cols*(i-1) + CC.PixelIdxList{j};
        ilium(ili3dP) = 1;
    end        
end

% The fill borders of elements which have pixels of one of the bones
for i = hipsStart:hipsEnd    
    filled = fillAxialHoles(hipsSeg(:,:,i));
    fill = filled - hipsSeg(:,:,i);
    CC = bwconncomp(fill,8);
    sacP = find(sacrum(:,:,i));        
    for j = 1:size(CC.PixelIdxList,2)        
        fill = fill & 0;                
        fill(CC.PixelIdxList{j}) = 1;
        border = imdilate(fill, strel('square',5)) - fill; 
        border = find(border);
        isSacMemb = max(ismember(border,sacP));
        if isSacMemb                  
            p3d = rows*cols*(i-1) + border;
            sacrum(p3d) = 1;
        end
    end
end

% Here we go up and down in the Z axis and take all
% assign the pixels which start near the line to one of the bones
% TODO explain this better
SHIFT = 5;
for t = 1:5
    if strcmp(side,'left')
        for i = hipsStart:hipsEnd
            for j = 1:cols
                p = find(sacrum(:,j,i),1,'first');
                p = p+SHIFT:round(rows/2);
                p3dUp = rows*cols*(i) + rows*(j-1) + p;
                sacrum(p3dUp) = 1;
                if i > 2
                    p3dLow = rows*cols*(i-2) + rows*(j-1) + p;
                    sacrum(p3dLow) = 1;
                end            
            end
        end
    end
end


sacrum = sacrum & hipsSeg;
            
end




