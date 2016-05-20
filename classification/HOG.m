function [ H ] = HOG( I, cell_x, cell_y, B )
% Apply HOG measurements to a grayscale image
I = double(I);
hx = [-1 0 1];
hy = [1 0 -1]';
Ix = double(imfilter(I, hx));
Iy = double(imfilter(I, hy));

Imag = sqrt(Ix.^2 + Iy.^2);
Iang = atan2(Iy, Ix);

[m, n] = size(I);
mH = floor(m/cell_y); 
nH = floor(n/cell_x);
H = zeros(mH, nH, B);

ang_ranges = linspace(-pi, pi, B+1);

for NYcell = 1:mH
    valid_y = (NYcell-1) * cell_y + 1;
    for NXcell = 1:nH
        valid_x = (NXcell-1) * cell_x + 1;
        for i = valid_y:valid_y + cell_y - 1;
            for j = valid_x:valid_x + cell_x - 1 
                for b = 1:size(ang_ranges,2)-1
                    if Iang(i,j) > ang_ranges(b) && Iang(i,j) < ang_ranges(b+1)
                        H(NYcell, NXcell, b) = H(NYcell, NXcell, b) + Imag(i,j);
                        % display(['Added ', num2str(Iang(i,j)), ' to b = ', num2str(b)]);
                    end
                    
                end
            end
        end
    end
end

% Normalization
for i = 1:mH
    for j = 1:nH
        Bvals = H(i,j,:);
        n = norm(Bvals(:));
        if n ~= 0
            H(i,j,:) = H(i,j,:)./n;
        else
           % display(['Zeros in i,j ', num2str(i) ,' ', num2str(j)]);
        end
    end
end

        

end

