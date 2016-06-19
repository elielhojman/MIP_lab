function [ graph ] = borderToGraph( border )
%BORDERTOGRAPH Summary of this function goes here
%   Detailed explanation goes here
[rows,cols,planes] = size(border);
graph = {};
j = 1;
for i=1:planes
    idxs = find(border(:,:,i)');
    idxs = rem(idxs-1,cols)+1; % As we take the transpose we take the cols for the remainder
    if numel(idxs) > 0
        shiftIdxs = circshift(idxs,1);
        diff = abs(idxs - shiftIdxs);
        linear = diff < std(diff);
        comps = bwconncomp(linear);
        [~,M] = max(cellfun(@numel,comps.PixelIdxList));
        idxs = idxs(comps.PixelIdxList{M});
        s = struct('values',idxs','plane',i);
        graph{j} = s;
        j = j+1;
    end
end
end

