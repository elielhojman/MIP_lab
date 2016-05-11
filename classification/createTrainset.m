%% Select points in the square to select images
diagList = diag1;
for i = 1:numel(diagList);
    name = diagList{i}.name;
    accNum = name(1:end-1);
    side = name(end);
    folderPath = ['sacro/dataset/',accNum];
    volMatFile = [folderPath, '/', accNum, '.mat'];
    borderMatFile = [folderPath,'/segBorder.mat'];
    if ~exist(volMatFile,'file') || ~exist(borderMatFile,'file')
        display(['Skipping ', name]);
        continue;
    end

    load(volMatFile); % The volume is under the variable 'vol'
    vol = dicom2niftiVol(vol,dicomInfo); % dicomInfo is also stored in the volMatFile

    load(borderMatFile); % The border segmentation is under 'segBorder', the ilium = 2 and the sacrum = 1;
    if side == 'R'
        seg = segBorder.R;
    else
        seg = segBorder.L;
    end

    sliceNum = Inf;
    pointsOfInterest = {};
    for j = size(vol,3):-1:1
        sliceNum = min([sliceNum,j]);
        if max(seg(:,:,sliceNum)) == 0
            continue;
        end
        roi = seg(:,:,sliceNum);
        roi(roi ~= 0) = 1; % Set values for ilium and sacrum to 1;
        try
            square = getConvhullSquare(roi);        
        catch
            display('Linear points in convhull');
            continue;
        end
        square = square + [-50 50 -50 50]; % increase the field of view
        % Make it same ratio
        diffX = square(2) - square(1);
        diffY = square(4) - square(3);
        M = max([diffX, diffY]);
        square = [square(1), square(1)+M, square(3), square(3)+M];
        % Display image
        try 
            close all;
            dataIn = input('(n)extSegmenation, ENTER next slice, number (slice number): ','s');
        catch
            display('Try again');
            dataIn = '';
        end        
        imagesc(vol(:,:,sliceNum)'); title(['Slice ', num2str(sliceNum)]);
        colormap gray(256);    
        axis(square);
        set(gca, 'CLim', [0, 700]);        
        if numel(dataIn) > 0
            if strcmp(dataIn,'n') || strcmp(dataIn,'N')
                break;
            end
            if min(isstrprop(dataIn,'digit'))
                sliceNum = str2num(dataIn);
                continue;
            end
        end
        shg;
        disp('Select points ');
        [x,y] = getpts();
        for k = 1:numel(x)
            s = struct('x',round(x),'y',round(y),'z',j,'accNum',accNum,'side',side,'diagnosis',diagList{i}.diagnosis);
            pointsOfInterest{end+1} = s;
        end
    end
end

