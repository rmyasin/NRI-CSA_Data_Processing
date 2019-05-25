% function trimBetweenTime: trims timestamped data between landmarks
% Note: the times in timeFull and trimTime are just numbers. trimTime must
% be in pairs such that the output time will be returned within each set of
% two adjacent elements in trimTime

% Inputs %
% data     - Nxm matrix of data, where N is # of datapoints of an m-feature vector
% timeFull - vector of length N of times when data was recorded
% timeTime - landmarks in pairs - data will be returned that belongs to the
%            time between timeTrim(ii) and timeTrim(ii+1) for ii=1,3,5,...
% isCell   - whether to return outputs as a long vector or as cell matrices
%            of each trimmed time couple

% Outputs % 
% data_trimmed - new vector of output data N2xm if isCell is false,
% otherwise a cell vector of matricies of size Nixm
% time_trimmed - times associated with data in data_trimmed

function [data_trimmed,time_trimmed]=trimBetweenTime(data,timeFull,trimTime,isCell)
if nargin<4
    isCell=false;
end
data_trimmed=[];
time_trimmed=[];
for i=1:2:length(trimTime)-1
    timeIndex=timeFull>=trimTime(i) & timeFull<=trimTime(i+1);
    if isCell
        data_trimmed{(i+1)/2}=data(timeIndex,:);
        time_trimmed{(i+1)/2}=timeFull(timeIndex,:);
    else
        data_trimmed=[data_trimmed;data(timeIndex,:)];
        time_trimmed=[time_trimmed;timeFull(timeIndex,:)];
    end
end

end