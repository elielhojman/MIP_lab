function [ sacrum, ilium ] = getSacrumIliumFromSeg( seg )
%GETSACRUMILIUMFROMSEG Summary of this function goes here
%   Detailed explanation goes here


sacrum = seg == 4 | seg == 1;
ilium = seg == 2 | seg == 3;

end

