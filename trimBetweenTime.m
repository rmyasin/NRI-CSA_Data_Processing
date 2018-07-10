function data_trimmed=trimBetweenTime(data,timeFull,trimTime)
data_trimmed=[];
for i=1:2:length(trimTime)
    data_trimmed=[data_trimmed;data(timeFull>=trimTime(i) & timeFull<=trimTime(i+1),:)];
end

end