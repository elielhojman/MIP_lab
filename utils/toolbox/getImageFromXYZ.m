function [img] = getImageFromXYZ(xyz, vol, pixelSz, imgSzMm, pixelImgSz, bone, side)
%GETIMAGEFROMXYZ Summary of this function goes here
%   Detailed explanation goes here
    % From size in militers to size in pixels    
    if nargin < 6
        bone = 'NA';
        side = 'NA';
    end
    
    shiftRight = 0;
    shiftLeft = 0;
    
    imgSz(1) = ceil(imgSzMm(1) / pixelSz(1));
    imgSz(2) = ceil(imgSzMm(2) / pixelSz(2));        
       
    if (strcmp(side,'L') && strcmp(bone,'sacrum') || ...
        (strcmp(side,'R') && strcmp(bone,'ilium')))
        shiftRight = 1;
    end
    
    if (strcmp(side,'R') && strcmp(bone,'sacrum') || ...
        (strcmp(side,'L') && strcmp(bone,'ilium')))
        shiftLeft = 1;
    end
    
    if shiftRight
        xRange = xyz(1) - round(imgSz(1)/3)*2:1:xyz(1) + round(imgSz(1)/3);        
    elseif shiftLeft % ShiftLeft
        xRange = xyz(1) - round(imgSz(1)/3):1:xyz(1) + round(imgSz(1)/3)*2;
    else
        xRange = xyz(1) - round(imgSz(1)/2):1:xyz(1) + round(imgSz(1)/2);
    end
    yRange = xyz(2) - round(imgSz(2)/2):1:xyz(2) + round(imgSz(2)/2);
    try
        im = vol(xRange, yRange, xyz(3) );     
    catch
        display('Out of bounds when recovering image');
        img = [];
        return 
    end
                    
    img = imresize(im,pixelImgSz);    

end

