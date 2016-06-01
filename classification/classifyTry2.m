% VSM on HOG representation
folderPath = 'images/allImgs/'
fileslist = dir([folderPath '*.gif']);
group = zeros(size(fileslist,1),1);
traindata = zeros(size(fileslist,1), 9*9*6); % 3*9*9 
normalize = 0;

B = 6;
cell_x = 4;
cell_y = 4;

for i = 1:size(fileslist,1)
    if logical(regexp(fileslist(i).name,'.*P.*'))    
        group(i) = 1;
    else
        group(i) = 0;
    end
    imdata = imread([folderPath, fileslist(i).name]);
    if normalize
        clearvars imdata2;
        imdata2 = double(imdata);
        imdata2 = imdata2./max(imdata2(:)) * 255.0;
        H = HOG(imdata2, cell_x, cell_y, B);
    else
        H = HOG(imdata, cell_x, cell_y, B);
    end
    Hconcat = H(:);
    traindata(i,:) = Hconcat';
end

% Train the svm
svmstruct = svmtrain(traindata, group);

% Classify the trained data
false_pos = 0;
% false_pos_list = [];
false_neg = 0;
% false_neg_list = 0;
clearvars false_pos_list false_neg_list

for i = 1:size(fileslist,1)
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


fileslistval = dir('dataset/valid/*.pgm')
for i = 1:size(fileslistval,1);
    f = fileslistval(i);
    imdata = imread(['dataset/valid/', f.name]);
    if normalize
        clearvars imdata2;
        imdata2 = double(imdata);
        imdata2 = imdata2./max(imdata2(:)) * 255.0;
        H = HOG(imdata2, cell_x, cell_y, B);
    else
        H = HOG(imdata, cell_x, cell_y, B);
    end    
    Hconcat = H(:);    
    res = svmclassify(svmstruct, Hconcat');
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

figure()

graph_vals = [false_neg_per false_pos_per; false_neg_val_per false_pos_val_per];
bar(graph_vals, 0.5, 'stacked')
legend('False negative', 'False positive');
set(gca,'XTickLabel',{'Training error', 'Validation error'});
ylabel('% Error')
ylim([0 10])
title('Training and Validation classification errors');
set(gca,'FontSize',12);
set(findall(gcf,'type','text'),'FontSize',14, 'fontWeight' ,'normal')
grid();

