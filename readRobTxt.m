function [cur,des,micron]=readRobTxt(folder,filename,baseLabel)
if nargin<3
    baseLabel=-1;
end

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
for index=1:nLab
    micron(index).label=micronLabels(index);
    indices=microndat(:,9)==micron(index).label;
    micron(index).time=microndat(indices,1);
    micron(index).pos=microndat(indices,2:4);
    micron(index).quatraw=microndat(indices,5:8);
    rot=quat2rotm(micron(index).quatraw);
    micron(index).rot=permute(rot,[2,1,3]); %Transpose the rotation which is opposite to what we'd expect
    micron(index).pose=[[micron(index).rot,reshape(micron(index).pos',3,1,[])];repmat([0,0,0,1],1,1,size(micron(index).pos,1))];
    micron(index).frame=microndat(indices,10);
end


if baseLabel>=0 % Perform premultiplication by the inverse of the base marker
    base=micron([micron.label]==baseLabel);
    basePose=base.pose;
    
    for index=1:nLab
        if micronLabels(index)~=baseLabel
            for jj=1:size(micron(index).pose,3)
                matchFrame=micron(index).frame(jj);
                if isempty(find(base.frame>matchFrame,1))
                    curBase=basePose(:,:,end);
                elseif find(base.frame>matchFrame,1)==1
                    curBase=basePose(:,:,1);
                else
                    curBase=basePose(:,:,find(base.frame>matchFrame,1)-1);
                end
                poseB(:,:,jj)=invtrans(curBase)*micron(index).pose(:,:,jj);
            end
            micron(index).pose=poseB;            
            micron(index).pos=squeeze(micron(index).pose(1:3,4,:))';
            micron(index).rot=micron(index).pose(1:3,1:3,:);
        end
    end
end


fclose(robfile);
end