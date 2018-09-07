clear
close all
clc


% Looking at the tool from the top
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

folder='R:\Projects\NRI\User_Study\Data\txtFile\';
filename='MicronTipCalib.txt';

[cur,des,micron]=readRobTxt(folder,filename);
Rmat=quat2rotm(micron{1}.quat); 
pos=micron{1}.pos;

%Remember micron gives the transpose of what I expect, so need to transpose Rmat
[tipLoc,baseLoc,centerPtList]=calibrateTool(pos,Rmat,1); 

plot3(pos(:,1),pos(:,2),pos(:,3),'.')
hold on
plot3(centerPtList(1,:),centerPtList(2,:),centerPtList(3,:),'rx')

[Center,Radius] = fitSphere(pos);
plot3(Center(1),Center(2),Center(3),'ko')
axis equal

errorPlot=sqrt(sum((centerPtList-mean(centerPtList,2)).^2));
mean(errorPlot) %0.54 mm error in reprojecting to center
figure
plot(errorPlot)



