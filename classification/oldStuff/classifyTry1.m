folderPathP = 'images/imgs_uint_P_resize/';
folderPathN = 'images/imgs_uint_N_resize/';
% folderPathP = 'images/imgs_uint_P/';
% folderPathN = 'images/imgs_uint_N/';  
%folderPathP = 'images/imgsP/';
%folderPathN = 'images/imgsN/';

fileslistP = dir([folderPathP '*.png']);
fileslistN = dir([folderPathN '*.png']);
fileslists = {fileslistP; fileslistN};
folderpaths = {folderPathP; folderPathN};
group = [];
traindata = [];
normalize = 0;
totalfiles = numel(fileslistP) + numel(fileslistN);
j = 1;
for k = 1:numel(fileslists)    
    fileslist = fileslists{k};
    folderPath = folderpaths{k};
    for i = 1:size(fileslist,1)
        if k == 1
            group(j) = 1;
        else
            group(j) = 0;
        end
        imdata = imread([folderPath, fileslist(i).name]);
        clearvars imdata2
        imdata2 = double(imdata(:));
        if normalize
            imdata2 = floor(imdata2./max(imdata2)*255);
        end
        traindata(j,:) = imdata2';
        j = j+ 1;
    end    
end

% Train the svm
svmstruct = svmtrain(traindata, group);

%% Classify the trained data
false_pos = 0;
% false_pos_list = [];
false_neg = 0;
% false_neg_list = 0;
clearvars false_pos_list false_neg_list

for i = 1:totalfiles
    res = svmclassify(svmstruct, traindata(i,:));
    % display([fileslist(i).name, ' = ', num2str(res)]);
    if logical(regexp(fileslist(i).name,'.*P.*'))
        if ~res
            false_neg = false_neg + 1;
            false_neg_list(false_neg) = fileslist(i);
        end
    else
        if res
            false_pos = false_pos + 1;
            false_pos_list(false_pos) = fileslist(i);
        end
    end
end

%% Classify validation data
% Classify the trained data
false_pos_val = 0;
clearvars false_pos_list_val false_neg_list_val
false_neg_val = 0;


fileslistval = dir([folderPath '*.pgm'])
for i = 1:size(fileslistval,1);
    f = fileslistval(i);
    imdata = double(imread(['dataset/valid/', f.name]));  
    imdata2 = double(imdata(:));
    if normalize
        imdata2 = floor(imdata2./max(imdata2)*255);
    end
    traindata(i,:) = imdata2';        
    res = svmclassify(svmstruct, imdata2');
    % display([fileslistval(i).name, ' = ', num2str(res)]);
    if logical(regexp(fileslistval(i).name,'.*P.*'))
        if ~res
            false_neg_val = false_neg_val + 1;
            false_neg_list_val(false_neg_val) = fileslistval(i);
        end
    else
        if res
            false_pos_val = false_pos_val + 1;
            false_pos_list_val(false_pos_val) = fileslistval(i);            
        end
    end
end

false_pos_per = false_pos * 100/size(fileslist,1)
false_neg_per = false_neg * 100/size(fileslist,1)
false_pos_val_per = false_pos_val *100/size(fileslistval,1)
false_neg_val_per = false_neg_val * 100/size(fileslistval,1)

graph_vals = [false_neg_per false_pos_per; false_neg_val_per false_pos_val_per];
bar(graph_vals, 0.5, 'stacked')
legend('False negative', 'False positive');
set(gca,'XTickLabel',{'Training error', 'Validation error'});
ylabel('% Error')
title('Training and Validation classification errors');
set(gca,'FontSize',12);
set(findall(gcf,'type','text'),'FontSize',14, 'fontWeight' ,'normal')





