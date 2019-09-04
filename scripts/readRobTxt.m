% Read a txt file of an experiment, convert it to a matlab struct of data
function [output]=readRobTxt(folder,filename)
%% Setup data structs
titleList={'psm_cur','psm_des','micron','psm_joint','camera','mtm_cur','force','micronTip','micronValid','poi_clear','poi_points','cam_minus','cam_plus','clutch','coag','display_points','artery_status','string_status','text','allow_points'};

micronNames={'micronA','micronB','micronC','micronD','micronRef','PROBE_A','PROBE_B','PROBE_C','PROBE_D','Ref'};
foundLabels=[50,51,52,53,60,50,51,52,53,60];

cur.time=[];
cur.pos=[];
des.time=[];
des.pos=[];
microndat=[];
joint.time=[];
joint.q=[];
mtm.time=[];
mtm.pos=[];
force.time=[];
force.data=[];

display_points.time=[];
display_points.data={};

artery_status.time=[];
artery_status.data=[];
string_status.time=[];
string_status.data=[];

text.time=[];
text.data={};


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

allow_points.time=[];
allow_points.data=[];

%% Start file reading
[~,dataFolderName]=fileparts(folder);

robfile=fopen([folder filesep filename]);
line=fgetl(robfile);
if length(line)>6 && strcmp(line(1:7),'Version')
    vProtocol=str2num(line(9:end));
    line=fgetl(robfile);
else
    vProtocol=1;
end

%% Read data depending on title name
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
%             case 3 % micron
%                 if vProtocol>=2
%                     cellArray=split(line);
%                     micronLabel=foundLabels(find(ismember(micronNames,cellArray{9})));
%                     numLine=[cellfun(@str2num,cellArray([1:8,10]));micronLabel]';
%                 end
%                 microndat=[microndat;numLine];
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
                poiPoints.data=[poiPoints.data;numLine(2:end)];
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
            case 16 %display_points
                display_points.time=[display_points.time;numLine(1)];
                display_points.data{end+1}=reshape(numLine(2:end),3,[]);
            case 17 %artery_status
                artery_status.time=[artery_status.time;numLine(1)];
                artery_status.data=[artery_status.data;numLine(2:end)];
            case 18 %string_status
                string_status.time=[string_status.time;numLine(1)];
                string_status.data=[string_status.data;numLine(2:end)];
            case 19 %text
                timeIndex=strfind(line,' ');
                text.time=[text.time;str2num(line(2:timeIndex-1))];
                text.data{end+1}=line(timeIndex(1)+2:end-1);
            case 20 % allow_points
                timeIndex=strfind(line,' ');
                allow_points.time=[allow_points.time;str2num(line(2:timeIndex-1))];
                allow_points.data=[allow_points.data;strcmp(line(timeIndex(1)+1:end),'True')];

        end
    end
    line=fgetl(robfile);
end

fclose(robfile);

%% Construct output data struct
dataList={cur,des,joint,mtm,force,micronTip,micronValid,poiClear,poiPoints,buttons,display_points,artery_status,text,allow_points,vProtocol};
titleList={'psm_cur','psm_des','psm_joint','mtm_cur','force','micronTip','micronValid','poi_clear','poi_points','buttons','display_points','artery_status','text','allow_points','version'};
output=cell2struct(dataList,titleList,2);

output.userNumber=str2double(dataFolderName(5:end));

end