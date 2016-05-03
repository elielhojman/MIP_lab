path = 'sacro/dataset/';
a = dir(path);
suffix = 'noCanny';
files = dir(path);
badSegWithCanny = {};
veryBadSegWithCanny = {};
goodSegWithCanny = {};
close all
for i = 1:numel(files)
    if findstr(a(i).name,suffix) > 0
        im = imread([path a(i).name]);
        imshow(im);shg;
        class = input('Good 0, Bad 1, VeryBad 2: ');
        strings = strsplit(a(i).name, '_');
        accNum = strings(1);
        side = a(i).name(end-4);
        segName = strcat(accNum, side);        
        if class == 0
            goodSegWithCanny{end+1} = segName; 
            display(['Good ' segName]);
        elseif class == 1
            badSegWithCanny{end+1} = segName;
            display(['Bad ' segName]);
        else
            veryBadSegWithCanny{end+1} = segName;
            display(['Very Bad ' segName]);
        end
    end
end
