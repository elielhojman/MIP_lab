function [ imNew ] = adjustContrast( im )
%ADJUSTCONTRAST Adjust the contrast of a CT image to display the bones
imNew = zeros(size(im)) + 200;
thresh = im > 200 & im < 1300;
imNew(thresh) = im(thresh);
thresh = im > 600 & im < 1300;
imNew(thresh) = 700;
imNew = (imNew - 200) / max(imNew(:));


end

