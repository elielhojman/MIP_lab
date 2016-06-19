function [ lbp ] = myLBP( im )
%MYLLBP Summary of this function goes here
%   Detailed explanation goes here
im = padarray(im,[1 1], 0);
[rows,cols] = size(im);

imf = im(:);
C = zeros(rows*cols,8);
j = 1;
for i = [1 -1 cols -cols cols+1 cols-1 -cols+1 -cols-1]
    C(:,j) = circshift(imf,i);
    j = j+1;
end

orig = repmat(imf,1,8);
words = C > orig;
weights = 2.^( [1:8] - 1);
weights = repmat(weights,size(C,1),1);
lbp = weights.*words;
lbp = sum(lbp,2);
lbp = reshape(lbp,rows,colstr);
lbp = lbp(2:end-1, 2:end-1);
end

