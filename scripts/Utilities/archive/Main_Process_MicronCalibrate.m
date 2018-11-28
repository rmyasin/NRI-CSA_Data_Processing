clear
close all
clc

% This is a script to find the tip of the micron tool and the differential
% homogeneous transforms that relate one marker on the tool to the next
% marker

% Looking at the tool from the top (B is the base marker for rotation)
%  ---B---
% |       |
% D       C
% |       |
%  ---A---

% Label mapping
% A: 50
% B: 51
% C: 52
% D: 53
% Base Marker: 60
labelList=[51,52,50,53];
baseLabel=60;

folder='R:\Projects\NRI\User_Study\Data\txtFile\';
filename='MicronTipCalib_Sept7.txt';

[cur,des,micron]=readRobTxt(folder,filename);

for ii=1:length(labelList)
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

    [Center,Radius] = fitSphere(pos);
    plot3(Center(1),Center(2),Center(3),'ko')
    axis equal

    errorFit=sqrt(sum((centerPtList-mean(centerPtList,2)).^2));
    mean(errorFit) %
    figure(2)
    subplot(2,2,ii)
    plot(errorFit)

    centerRot(:,ii)=mean(centerPtList,2);
    
    %% Find the differential pose
    if ii==length(labelList)
        nextLabel=labelList(1);
    else
        nextLabel=labelList(ii+1);
    end
    nextIndex=[micron.label]==nextLabel;
    M1=micron(index);
    M2=micron(nextIndex);
    frame1=M1.frame;
    frame2=M2.frame;
    [~,idF1,idF2] = intersect(frame1,frame2);
    
    R1= M1.rot(:,:,idF1);
    R2= M2.rot(:,:,idF2);
    
    for jj=1:length(idF1)        
        R12(:,:,jj)=R1(:,:,jj)'*R2(:,:,jj);
        % From AX=B, X=A-1 B, and definition of inverse homogeneous
        % transform, dx=R1' d2 - R1' d1
        d12(:,jj)=R1(:,:,jj)'*M2.pos(idF2(jj),:)' - R1(:,:,jj)' * M1.pos(idF1(jj),:)';
        
        H1(:,:,jj) = transformation(R1(:,:,jj),M1.pos(idF1(jj),:));
        H2(:,:,jj) = transformation(R2(:,:,jj),M2.pos(idF2(jj),:));
        H12(:,:,jj)=inv(H1(:,:,jj))*H2(:,:,jj);        
    end
    R12Ave=averageRotations(H12(1:3,1:3,:));
    if ii==3 % Data corruption, do some manual trickery
        HNextMarker(:,:,ii)=transformation(R12Ave,mean(H12(1:3,4,1:80),3));
    else
        HNextMarker(:,:,ii)=transformation(R12Ave,mean(H12(1:3,4,:),3));
    end
    H1(:,:,5)*HNextMarker(:,:,ii)-H2(:,:,5) % Training error example
end

% Loop error going around the 'circle'
HNextMarker(:,:,1)*HNextMarker(:,:,2)*HNextMarker(:,:,3)*HNextMarker(:,:,4)


save('tip_calibration','tipLoc','labelList','HNextMarker')