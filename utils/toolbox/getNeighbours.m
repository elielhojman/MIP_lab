function [ n ] = getNeighbours( mat, idx, conn, onlyBigger )
%GETNEIGHBOURS Get the indexes of the neighbours pixels
%   INPUTS:
%     mat  - The matrix where the pixels are located
%     idx - Index of the relevant node
%     conn - Which neighbours to retrieve. Valid values (4, 8, 10, 18, 26)
%     onlyBigger - Return neighbours with index bigger than idx
%   OUTPUTS:
%     n - indexes of neighbours   

if nargin < 4
    onlyBigger = 0;
end

if conn ~= 4 && conn ~= 8 && conn ~= 10 && conn ~= 18 && conn ~= 26
    error('Select conn to be 4, 8, 10, 18 or 26');
end

[y, x, z] = size(mat);
n = []; % neighbours
if conn >= 4
    n = [n idx-y idx-1 idx+1 idx+y];
end

if conn >= 8
    n = [n idx-y-1 idx-y+1 idx+y-1 idx+y+1];
end

if conn >= 10
    n = [n idx-(x*y) idx+(x*y)];
end

if conn >= 18
    upIdx = idx+(x*y);
    downIdx = idx-(x*y);    
    n = [n upIdx-y upIdx-1 upIdx+1 upIdx+y];
    n = [n downIdx-y downIdx-1 downIdx+1 downIdx+y];
end

if conn >= 26
    upIdx = idx+(x*y);
    downIdx = idx-(x*y);    
    n = [n upIdx-y-1 upIdx-y+1 upIdx+y-1 upIdx+y+1];
    n = [n downIdx-y-1 downIdx-y+1 downIdx+y-1 downIdx+y+1];
end

n = reshape(n',numel(n),1);
idx = repmat(idx,1,conn)';
idx = reshape(idx, numel(idx),1);
n = [n idx];

if onlyBigger == 1
    n = n(n(:,1) > n(:,2),:);
end

    

end

