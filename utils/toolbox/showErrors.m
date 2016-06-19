function [  ] = showErrors( predictedLabels, knownLabels, ...
    labelToPrint, imSet, score, threshold, success)
%SHOWERRORS Summary of this function goes here
%   Detailed explanation goes here
imSet = imSet(labelToPrint);
idxs = knownLabels == labelToPrint;
predictedLabels = predictedLabels(idxs);
diff = abs(score(idxs,1) - score(idxs,2));
score = score(idxs, :);
for i = 1:numel(predictedLabels)    
    if (labelToPrint == predictedLabels(i)) == success && diff(i) > threshold % error in prediction            
            im = read(imSet,i);
            imagesc(im); colormap gray; title(abs(score(i,1) - score(i,2)));
            shg; pause;
    end
end
end

