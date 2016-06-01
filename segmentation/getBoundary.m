function [boundary] = getBoundary(seg, side)
    %GETBOUNDARY Get the outer boundary of the border segmentation
    boundary = zeros(size(seg));
    idxs = [];
    [rows,cols,~] = size(seg);    
    for i = 1:size(seg,3)
        plane = seg(:,:,i)';
        plane = fliplr(plane);
        for j = 1:rows;
            row = plane(j,:);
            idxRow = 0;
            if side == 'L'
                idxRow = find(row,1,'first');
            else % last
                idxRow = find(row,1,'last');
            end
            if idxRow                
                idxs(end+1) = (i-1)*(rows*cols) + (idxRow-1)*cols + j;
            end            
        end
    end
    boundary(idxs) = 1;
    for i = 1:size(seg,3);
        plane = boundary(:,:,i);
        boundary(:,:,i) = (fliplr(plane))';
    end
    
end



