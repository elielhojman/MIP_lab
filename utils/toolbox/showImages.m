function showImages(imgs, n, titleStr)
figure;
if nargin < 2
    n = 9;
end

idx = ceil(sqrt(n));


for i = 1:n
    subplot(idx,idx,i);

    if iscell(imgs)
        imagesc(imgs{i})
    else
        imagesc(imgs(:,:,i));
    end
    colormap gray(256);
    axis image;
    if i == 1
        if exist('titleStr','var')
             title(titleStr);
        end
    end
end

end
