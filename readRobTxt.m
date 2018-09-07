function [cur,des,micron]=readRobTxt(folder,filename)
robfile=fopen([folder filename]);
titleList={'psm_cur','psm_des','micron'};
line=fgetl(robfile);

cur.time=[];
cur.pos=[];
des.time=[];
des.pos=[];
microndat=[];

while line~=-1
    temp=find(strcmp(line,titleList));
    if temp
        typeIndex=temp;
    else
        numLine=str2num(line);
        switch typeIndex
            case 1
                cur.time=[cur.time;numLine(1)];
                cur.pos=[cur.pos;numLine(2:end)];
            case 2
                des.time=[des.time;numLine(1)];
                des.pos=[des.pos;numLine(2:end)];
            case 3
                microndat=[microndat;numLine];
        end
    end
    line=fgetl(robfile);
end

micronLabels=unique(microndat(:,9));
nLab=length(micronLabels);
for i=1:nLab
    micron{i}.label=micronLabels(i);
    indices=microndat(:,9)==micron{i}.label;
    micron{i}.time=microndat(indices,1);
    micron{i}.pos=microndat(indices,2:4);
    micron{i}.quat=microndat(indices,5:8);
    micron{i}.frame=microndat(indices,10);
end

fclose(robfile);
