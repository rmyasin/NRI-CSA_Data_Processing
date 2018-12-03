
% This is a script to find the tip of the micron tool and the differential
% homogeneous transforms that relate one marker on the tool to the next
% marker

% Looking at the tool from the top (B is the base marker for rotation)
%  ---C---
% |       |
% D       B
% |       |
%  ---A---

% Label mapping
% A: 50
% B: 51
% C: 52
% D: 53
% Base Marker: 60

clear
close all
filefolder='/home/arma/catkin_ws/src/processing.git/data/tipCalibration1130/';
filenames={'Atip.txt','Btip.txt','Ctip.txt','Dtip.txt','AB.txt','BC.txt','CD.txt','DA.txt'}
% function tip_calibration = pivot_calibration_multifile(filefolder, fileNames)

% SEEMS TO BE A PROBLEM WITH CD, AND MAYBE DA, BUT MAY BE OK, NEED
% INVESTIGATION


labelList=[50,51,52,53]; % List order A, B, C, D, frame rotation matches A


for ii=1:4
    [~,~,micron,~,vProtocol]=readRobTxt(filefolder,filenames{ii});
    
    index=[micron.label]==labelList(ii);
    pos=micron(index).pos;
    
    %% Find the calibrated tip point
    % Erase outliers from sphere fit
    [Center,Radius] = fitSphere(pos);
    errorSphere=sqrt(sum((pos-Center).^2,2))-Radius;
    badIndex=isoutlier(errorSphere);
    pos=micron(index).pos(~badIndex,:);
    
    Rmat=micron(index).rot(:,:,~badIndex);
    
    %Remember micron gives the transpose of what I expect, so need to transpose Rmat
    [tipLoc(:,ii),baseLoc,centerPtList]=calibrateTool(pos,Rmat);
    
    figure(1)
    plot3(pos(:,1),pos(:,2),pos(:,3),'.')
    hold on
    plot3(centerPtList(1,:),centerPtList(2,:),centerPtList(3,:),'x')
    meanCenter=mean(centerPtList,2);
    plot3(meanCenter(1),meanCenter(2),meanCenter(3),'ro')
    
    [Center,~] = fitSphere(pos);
    plot3(Center(1),Center(2),Center(3),'ko')
    axis equal
    
    errorFit=sqrt(sum((centerPtList-meanCenter).^2));
    
    figure(2)
    subplot(2,2,ii)
    plot(errorFit)
    xlabel('Experiment Progress');
    ylabel('Error (mm)')
    title('Pivot Center Error')
    
end

for ii=1:4
    [~,~,micron,~,vProtocol]=readRobTxt(filefolder,filenames{ii+4});
    
    %% Find the differential pose
    if ii==length(labelList)
        nextLabel=labelList(1);
    else
        nextLabel=labelList(ii+1);
    end
    nextIndex=[micron.label]==nextLabel;
    M1=micron(index);
    M2=micron(nextIndex);
    
    switch vProtocol
        case 1
            frame1=M1.frame;
            frame2=M2.frame;
            [~,idF1,idF2] = intersect(frame1,frame2);
            
            R1= M1.rot(:,:,idF1);
            R2= M2.rot(:,:,idF2);
        case 2
            time1=(M1.time-M1.time(1))/1E9;
            time2=(M2.time-M1.time(1))/1E9;
            
            timeMat=abs(repmat(time1,1,size(time2,1))-repmat(time2',size(time1,1),1));
            [timediff,in]=min(timeMat,[],2);
            idF1=find(timediff<0.1);
            idF2=in(timediff<0.1);
            R1=M1.rot(:,:,idF1);
            R2=M2.rot(:,:,idF2);
    end
    
    d12=zeros(3,length(idF1));
    R12=zeros(3,3,length(idF1));
    H1=zeros(4,4,length(idF1));
    H2=zeros(4,4,length(idF1));
    H12=zeros(4,4,length(idF1));
    
    for jj=1:length(idF1)
        R12(:,:,jj)=R1(:,:,jj)'*R2(:,:,jj);
        % From AX=B, X=A-1 B, and definition of inverse homogeneous
        % transform, dx=R1' d2 - R1' d1
        d12(:,jj)=R1(:,:,jj)'*M2.pos(idF2(jj),:)' - R1(:,:,jj)' * M1.pos(idF1(jj),:)';
        
        H1(:,:,jj) = transformation(R1(:,:,jj),M1.pos(idF1(jj),:));
        H2(:,:,jj) = transformation(R2(:,:,jj),M2.pos(idF2(jj),:));
        H12(:,:,jj)=inv(H1(:,:,jj))*H2(:,:,jj);
    end
    
    %     Plot the differential transform to see outliers, trim them using
    %     subIndex variable
    figure
    for first=1:3
        for second=1:3
            if exist('subIndex','var')
                plot(squeeze(H12(first,second,subIndex)));
            else
                plot(squeeze(H12(first,second,:)));
            end
            hold on
        end
    end
    
    % if exist('subIndex','var')
    %     R12Ave=averageRotations(H12(1:3,1:3,subIndex));
    %     HNextMarker(:,:,ii)=transformation(R12Ave,mean(H12(1:3,4,subIndex),3));
    % else
    R12Ave=averageRotations(H12(1:3,1:3,:));
    HNextMarker(:,:,ii)=transformation(R12Ave,mean(H12(1:3,4,:),3));
    % end
end


% Loop error going around the 'circle'
loopError=HNextMarker(:,:,1)*HNextMarker(:,:,2)*HNextMarker(:,:,3)*HNextMarker(:,:,4)

H_TipFrame(:,:,1)=transformation(eye(3),tipLoc(:,1));
H_TipFrame(:,:,2)=transformation(HNextMarker(1:3,1:3,1)',tipLoc(:,2));
test1=(HNextMarker(1:3,1:3,1)*HNextMarker(1:3,1:3,2))';
test2=HNextMarker(1:3,1:3,3)*HNextMarker(1:3,1:3,4);
H_TipFrame(:,:,3)=transformation(averageRotations(test1(1:3,1:3),test2(1:3,1:3)),tipLoc(:,3));
H_TipFrame(:,:,4)=transformation(HNextMarker(1:3,1:3,1),tipLoc(:,4));

%% Save mat file and yaml file
save('tip_calibration','tipLoc','labelList','HNextMarker','H_TipFrame')

fileID = fopen('tip_calibration.yaml','w');
for i=1:4
    fprintf(fileID,'# Marker Number\r\n');
    fprintf(fileID,'marker_%d:\r\n',i);
    fprintf(fileID,'# Tip Position\r\n');
    fprintf(fileID,'  pos: [%f, %f, %f]\r\n',H_TipFrame(1:3,4,i));
    fprintf(fileID,'# Tip Orientation [w x y z]\r\n');
    fprintf(fileID,'  quat: [%f, %f, %f, %f]\r\n',rotm2quat(H_TipFrame(1:3,1:3,i)));
end
fclose(fileID);

%% Return calibration result
tip_calibration.tipLoc=tipLoc;
tip_calibration.labelList=labelList;
tip_calibration.HNextMarker=HNextMarker;
tip_calibration.H_TipFrame=H_TipFrame;

% end