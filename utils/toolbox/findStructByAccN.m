function [ s ] = findStructByAccN( accNum, arrayCell )
%FINDSTRUCTBYACCN Summary of this function goes here
%   Detailed explanation goes here
s = {};
for i = 1:numel(arrayCell)
    if isfield(arrayCell{i},'accessNum')
        if strcmp(arrayCell{i}.accessNum,accNum);
            s = arrayCell{i};
        end
    end
end

end

