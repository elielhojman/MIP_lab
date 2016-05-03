function [ output_args ] = getRoughness( accNum, side )
%GETROUGHNESS Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    side = 'NONE';
end

load(['sacro/dataset/' accNum,'/segmentationNoCanny.mat']);
if strcmp(side,'L') || strcmp(side,'NONE')
    bSac = getOuterBorder('L',seg,'sacrum');
    bIl = getOuterBorder('L',seg,'ilium');
    gSac = borderToGraph(bSac);
    gIl = borderToGraph(bIl);
    roughSac = getBorderRoughness(gSac);
    roughIl = getBorderRoughness(gIl);
    printValues(roughSac, 'sacrum','L');
    printValues(roughIl, 'ilium','L');   
end

if strcmp(side,'R') || strcmp(side,'NONE')
    bSac = getOuterBorder('R',seg,'sacrum');
    bIl = getOuterBorder('R',seg,'ilium');
    gSac = borderToGraph(bSac);
    gIl = borderToGraph(bIl);
    roughSac = getBorderRoughness(gSac);
    roughIl = getBorderRoughness(gIl);
    printValues(roughSac, 'sacrum','R');
    printValues(roughIl, 'ilium','R');   
end

end

function printValues(roughness,boneType,side)
    display(['Roughness ', boneType,' ', side, ': MAX MEAN STD']);
    disp(max(roughness)); disp(mean(roughness)); disp(std(roughness));
end