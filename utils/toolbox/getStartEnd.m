function [ startS, endS ] = getStartEnd( segmentation )
%GETSTARTEND Returns the start and end of a segmentation in the Z plane

startS = 0;
endS = 0;
% Find hipsStart and End
for i = 1:size(segmentation,3)
    if startS == 0 && numel(find(segmentation(:,:,i), 1, 'first'))
        startS = i;
    end
    if startS ~=0 && ~numel(find(segmentation(:,:,i), 1, 'first'))
        endS = i-1;
        break;
    end
end

end

