function [ roughness ] = getBorderRoughness( graph )
roughness = [];
ORDER = 20;
if iscell(graph)   
    for i = 1:numel(graph)
        x = 1:numel(graph{i}.values);
        x = (x-1)/100;
        P = polyfit(x,graph{i}.values,ORDER);
        yHat = polyval(P,x);
        error = mean(abs(graph{i}.values - yHat));
        roughness(i) = error;
    end
else
    for i = 1:size(graph,1)
        x = 1:numel(graph(i,:));
        x = (x-1)/100;
        P = polyfit(x,graph(i,:),ORDER);
        yHat = polyval(P,x);
        error = mean(abs(graph(i,:) - yHat));
        roughness(i) = error;
    end    
end
