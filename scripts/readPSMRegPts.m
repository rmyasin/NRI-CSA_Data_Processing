function [rob,micron]=readPSMRegPts(folder,filename)
titleList={'Rob Pts at A','Rob Pts at B','Rob Pts at C','Rob Pts at D','Micron Pts at A','Micron Pts at B','Micron Pts at C','Micron Pts at D'};

% [~,dataFolderName]=fileparts(folder);

robfile=fopen([folder filesep filename]);


line=fgetl(robfile);
rob.pos{1}=[];
rob.pos{2}=[];
rob.pos{3}=[];
rob.pos{4}=[];
rob.quat{1}=[];
rob.quat{2}=[];
rob.quat{3}=[];
rob.quat{4}=[];

micron.pos{1}=[];
micron.pos{2}=[];
micron.pos{3}=[];
micron.pos{4}=[];
micron.quat{1}=[];
micron.quat{2}=[];
micron.quat{3}=[];
micron.quat{4}=[];

while line~=-1
    temp=find(strcmp(line,titleList));
    if temp
        typeIndex=temp;
    else
        numLine=str2num(line);        
        
        % Rob pts at @
        if typeIndex>0 && typeIndex<=4
            rob.pos{typeIndex}(end+1,:)=numLine;
            line=fgetl(robfile);
            numLine=str2num(line);
            rob.quat{typeIndex}(end+1,:)=numLine;
        % Micron Pts at @
        elseif typeIndex<=8
            micron.pos{typeIndex-4}(end+1,:)=numLine;
            line=fgetl(robfile);
            numLine=str2num(line);
            micron.quat{typeIndex-4}(end+1,:)=numLine;
        end
    end
    line=fgetl(robfile);
end

%%
fclose(robfile);

% dataList={cur,des,joint,mtm,force,micronTip,micronValid,poiClear,poiPoints,buttons,display_points,artery_status,text,allow_points,vProtocol};
% titleList={'psm_cur','psm_des','psm_joint','mtm_cur','force','micronTip','micronValid','poi_clear','poi_points','buttons','display_points','artery_status','text','allow_points','version'};
% % output=cell2struct(dataList,titleList,2);
% 
% % output.userNumber=str2double(dataFolderName(5:end));

end