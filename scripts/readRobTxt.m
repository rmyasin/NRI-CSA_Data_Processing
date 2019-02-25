function [output,vProtocol]=readRobTxt(folder,filename,baseLabel)
if nargin<3
    baseLabel=-1;
end
titleList={'psm_cur','psm_des','micron','psm_joint','camera','mtm_cur','force','micronTip','micronValid','poi_clear','poi_points','cam_minus','cam_plus','clutch','coag'};


robfile=fopen([folder filesep filename]);
line=fgetl(robfile);
if length(line)>6 && strcmp(line(1:7),'Version')
    vProtocol=str2num(line(9:end));
    line=fgetl(robfile);
else
    vProtocol=1;
end

micronNames={'micronA','micronB','micronC','micronD','micronRef','PROBE_A','PROBE_B','PROBE_C','PROBE_D','Ref'};
foundLabels=[50,51,52,53,60,50,51,52,53,60];

cur.time=[];
cur.pos=[];
des.time=[];
des.pos=[];
microndat=[];
joint.time=[];
joint.q=[];
cameraTime=[];
mtm.time=[];
mtm.pos=[];
force.time=[];
force.data=[];

micronTip.time=[];
micronTip.pos=[];
micronTip.quat=[];
micronTip.seq=[];
micronValid.time=[];
micronValid.data=[];

poiPoints.time=[];
poiPoints.data=[];

poiClear.time=[];
poiClear.data=[];

buttons.camera.time=[];
buttons.camera.push=[];
buttons.coag.time=[];
buttons.coag.push=[];
buttons.camplus.time=[];
buttons.camplus.push=[];
buttons.camminus.time=[];
buttons.camminus.push=[];
buttons.clutch.time=[];
buttons.clutch.push=[];

while line~=-1
    temp=find(strcmp(line,titleList));
    if temp
        typeIndex=temp;
    else
        numLine=str2num(line);        
        switch typeIndex
            case 1 % psm_cur
                cur.time=[cur.time;numLine(1)];
                cur.pos=[cur.pos;numLine(2:end)];
            case 2 % psm_des
                des.time=[des.time;numLine(1)];
                des.pos=[des.pos;numLine(2:end)];
            case 3 % micron
                if vProtocol>=2
                    cellArray=split(line);
                    micronLabel=foundLabels(find(ismember(micronNames,cellArray{9})));
                    numLine=[cellfun(@str2num,cellArray([1:8,10]));micronLabel]';
                end
                microndat=[microndat;numLine];
            case 4 % psm_joint
                if length(numLine)>1 %If full data written, save data
                    joint.time=[joint.time;numLine(1)];
                    joint.q=[joint.q;numLine(2:end)];
                end
            case 5 % camera
                buttons.camera.time=[buttons.camera.time;numLine(1)];
                buttons.camera.push = [buttons.camera.push;numLine(2:end)];
            case 6 % mtm_cur
                mtm.time=[mtm.time;numLine(1)];
                mtm.pos=[mtm.pos;numLine(2:end)];
            case 7 %force
                force.time=[force.time;numLine(1)];
                force.data=[force.data;numLine(2:end)];
            case 8% micronTip
                micronTip.time=[micronTip.time;numLine(1)];
                micronTip.pos=[micronTip.pos;numLine(2:4)];
                micronTip.quat=[micronTip.quat;numLine(5:8)];
                micronTip.seq=[micronTip.seq;numLine(9)];
            case 9  %micronValid
                spaceIn=strfind(line,' ');
                micronValid.time=[micronValid.time;str2double(line(1:spaceIn(1)))];
                topicName=line(spaceIn(1)+1:spaceIn(2)-1);
                slashIn=strfind(topicName,'/');
                micronFind=topicName(slashIn(2)+1:slashIn(3)-1);
                micronIn=strcmp(micronNames,micronFind);
                micronValid.probeNum=foundLabels(micronIn);
                micronValid.data=[micronValid.data;strcmp(line(spaceIn(end)+1:end),'True')];
            case 10 %poi_clear
                poiClear.time=[poiClear.time;numLine(1)];
                poiClear.data=[poiClear.time;numLine(2:end)];
            case 11 %poi_points
                poiPoints.time=[poiPoints.time;numLine(1)];
                poiPoints.data=[poiPoints.time;numLine(2:end)];
            case 12 % cam_minus
                buttons.camminus.time=[buttons.camminus.time;numLine(1)];
                buttons.camminus.push = [buttons.camminus.push;numLine(2:end)];
            case 13 % cam_plus
                buttons.camplus.time=[buttons.camplus.time;numLine(1)];
                buttons.camplus.push = [buttons.camplus.push;numLine(2:end)];
            case 14 % clutch
                buttons.clutch.time=[buttons.clutch.time;numLine(1)];
                buttons.clutch.push = [buttons.clutch.push;numLine(2:end)];
            case 15 % coag
                buttons.coag.time=[buttons.coag.time;numLine(1)];
                buttons.coag.push = [buttons.coag.push;numLine(2:end)];
        end
    end
    line=fgetl(robfile);
end

%% Post-process raw Micron data
if ~isempty(microndat)
    if vProtocol ==1
        foundLabels=unique(microndat(:,9));
    else
        foundLabels=unique(microndat(:,10));
    end
    nLab=length(foundLabels);
    
    for index=1:nLab
        micron(index).label=foundLabels(index);
        if vProtocol==1
                indices=microndat(:,9)==micron(index).label;
                micron(index).frame=microndat(indices,10);
        else
                indices=microndat(:,10)==micron(index).label;
                micron(index).seq=microndat(indices,9);
        end
        micron(index).time=microndat(indices,1);
        micron(index).pos=microndat(indices,2:4);
        micron(index).quatraw=microndat(indices,5:8);
        rot=quat2rotm(micron(index).quatraw);
        micron(index).rot=rot;
        micron(index).pose=[[micron(index).rot,reshape(micron(index).pos',3,1,[])];repmat([0,0,0,1],1,1,size(micron(index).pos,1))];
    end
    
    %TODO: FINISH THIS - PROTOCOL CURRENTLY DOESN'T MATCH JHU ANYWAY, SO
    %MAYBE BEST TO DROP THIS AND PICK BACK UP AFTER UNIFYING
%     if baseLabel>=0 % Perform premultiplication by the inverse of the base marker
%         base=micron([micron.label]==baseLabel);
%         basePose=base.pose;
%         
%         for index=1:nLab
%             if foundLabels(index)~=baseLabel
%                 for jj=1:size(micron(index).pose,3)
%                     matchFrame=micron(index).frame(jj);
%                     if isempty(find(base.frame>matchFrame,1))
%                         curBase=basePose(:,:,end);
%                     elseif find(base.frame>matchFrame,1)==1
%                         curBase=basePose(:,:,1);
%                     else
%                         curBase=basePose(:,:,find(base.frame>matchFrame,1)-1);
%                     end
%                     poseB(:,:,jj)=invtrans(curBase)*micron(index).pose(:,:,jj);
%                 end
%                 micron(index).pose=poseB;
%                 micron(index).pos=squeeze(micron(index).pose(1:3,4,:))';
%                 micron(index).rot=micron(index).pose(1:3,1:3,:);
%             end
%         end
%     end
else
    micron=[];
end
%%
fclose(robfile);


dataList={cur,des,microndat,joint,mtm,force,micronTip,micronValid,poiClear,poiPoints,buttons};
titleList={'psm_cur','psm_des','micron','psm_joint','mtm_cur','force','micronTip','micronValid','poi_clear','poi_points','buttons'};
output=cell2struct(dataList,titleList,2);

end