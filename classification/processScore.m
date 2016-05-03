function [ score ] = processScore( scoreOld )
%PROCESSSCORE Summary of this function goes here
%   Detailed explanation goes here
% scoreOld 
% [dilate_1px ..._2px ..._3px ..._4px 
score = scoreOld;
return;
score = scoreOld([1:2]) * 1e6;
score = score/(scoreOld(6)*scoreOld(7));
score = [score];

end

