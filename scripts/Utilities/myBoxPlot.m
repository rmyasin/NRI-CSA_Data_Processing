% This function is a wrapper for the native MATLAB boxplot function
% For boxplots with datasets of varying lengths, id numbers must be assigned to
% each datapoint to associate it with its respective dataset. By passing a
% cell list of datasets, this function is more compact

% Test usage:
% mydata1=randn(5,1);
% mydata2=randn(18,1);
% myBoxPlot({mydata1,mydata2},{'one','two'})


function myBoxPlot(cellList,labels,b_scatter,scatterSize)
if nargin<4
    scatterSize=6;
end
if nargin<3
    b_scatter=0;
end
labelID=[];

for i=1:length(cellList)
    if iscolumn(cellList{i})
        cellList{i}=cellList{i}'; %Make all data rows
    end
    labelID=[labelID,ones(size(cellList{i}))*i];
end

data=[cellList{:}];

boxplot(data,labelID,'labels',labels);
if b_scatter
    hold on
    for i=1:length(cellList)
        if b_scatter==1
            plot(linspace(i-.15,i+.15,length(cellList{i})),cellList{i},'b.','MarkerSize',scatterSize);
        else
            plot(i,cellList{i},'b.','MarkerSize',scatterSize);
        end
    end
end
end