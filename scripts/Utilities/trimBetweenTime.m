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