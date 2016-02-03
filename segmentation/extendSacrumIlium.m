function [  sacrum, ilium ] = extendSacrumIlium( hipsSeg, sacrum, ilium, side )
%EXTENDSACRUMILIUM Extend the identification of points for scarum and ilium
%   We go over the axial pictures and for full components that do not have
%   any points which belong both to ilium and sacrum we extend them to
%   belong to only one of them. 
% INPUTS
%  - hipsSeg, hips segmentation
%  - sacrum, points previously defined as belonging to the sacrum
%  - ilium, points previously defined as belonging to the ilium
  
display('Extend Sacrum-Ilium');
[hipsStart, hipsEnd] = getStartEnd(hipsSeg);
[rows,cols,~] = size(hipsSeg);
extendStart = hipsStart + round ( (hipsEnd-hipsStart)/ 2);
for i = [hipsStart:hipsStart+6 extendStart:hipsEnd];
    sacP = find(sacrum(:,:,i));
    iliP = find(ilium(:,:,i));
    CC = bwconncomp(hipsSeg(:,:,i));
    if CC.NumObjects > 5 && ~(i >= hipsEnd - 10) % We want to be sure the sacrum don't get parts of the ilium
        continue;
    end
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

% Here we go up and down in the Z axis and take all
% assign the pixels which start near the line to one of the bones
% TODO explain this better
SHIFT = 4;
filterToR = zeros(SHIFT*2+1,SHIFT*2+1,3);
filterToL = zeros(SHIFT*2+1,SHIFT*2+1,3);

filterToR(1,SHIFT+1,1) = 1;
filterToR(1,SHIFT+1,3) = 1;
filterToR(SHIFT+1,SHIFT+1,2) = 1;

filterToL(end,SHIFT+1,1) = 1;
filterToL(end,SHIFT+1,3) = 1;
filterToL(SHIFT+1,SHIFT+1,2) = 1;

for t = 1:4
    if strcmp(side,'right')        
        sacrum = imfilter(sacrum,filterToR,'same');                                   
        ilium = imfilter(ilium, filterToL,'same');
    else
        sacrum = imfilter(sacrum,filterToL,'same');                                   
        ilium = imfilter(ilium, filterToR,'same');
    end
end

sacrum = sacrum & hipsSeg;
ilium = ilium & hipsSeg;

% The fill borders of elements which have pixels of one of the bones
for i = hipsStart:hipsEnd    
    filled = fillAxialHoles(hipsSeg(:,:,i));
    fill = filled - hipsSeg(:,:,i);
    CC = bwconncomp(fill,8);
    sacP = find(sacrum(:,:,i));     
    iliP = find(ilium(:,:,i));
    for j = 1:size(CC.PixelIdxList,2)        
        fill = fill & 0;                
        fill(CC.PixelIdxList{j}) = 1;
        border = imdilate(fill, strel('square',5)) - fill; 
        border = find(border);
        isSacMemb = max(ismember(border,sacP));
        isIliMemb = max(ismember(border,iliP));
        if isSacMemb && ~isIliMemb                  
            p3d = rows*cols*(i-1) + border;
            sacrum(p3d) = 1;
        end
        if isIliMemb && ~isSacMemb
            p3d = rows*cols*(i-1) + border;
            ilium(p3d) = 1;
        end
    end
end

sacrum = sacrum & hipsSeg;
ilium = ilium & hipsSeg;
            
end




