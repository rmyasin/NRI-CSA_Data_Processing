clear
% close all
clc

% This is a script to find the locations of the 4 organ-fiducials of the
% organ-holding stand in the frame of the micron tracker (and a local fixed
% marker). 

labelList=[51,52,50,53];
baseLabel=60;

folder='R:\Projects\NRI\User_Study\Data\txtFile\';
filename='MicronCornerCalib_Sept7_II.txt';

baseLabel=60; %Automatically apply base frame offset using label 60
[cur,des,micron]=readRobTxt(folder,filename,baseLabel);

a=load('tip_calibration');

A=1:584;
B=585:1168;
C=1169:1786;
D=1787:2267;
vein=2268:3148;
for ii=1%:length(a.labelList)
    
    curLabel=a.labelList(ii);
    index=[micron.label]==labelList(ii);
    
    if find(index)
        pos=micron(index).pos;
        rot=micron(index).rot;
        pose=micron(index).pose;
        for jj=1:size(pose,3)
            tip(:,jj)=pose(:,:,jj)* [a.tipLoc(:,a.labelList==curLabel);1];
        end
        
        [tipNew{1},baseNew{1},ptList{1}]=calibrateTool(pos(A,:),rot(:,:,A)); 
        [tipNew{2},baseNew{2},ptList{2}]=calibrateTool(pos(B,:),rot(:,:,B)); 
        [tipNew{3},baseNew{3},ptList{3}]=calibrateTool(pos(C,:),rot(:,:,C)); 
        [tipNew{4},baseNew{4},ptList{4}]=calibrateTool(pos(D,:),rot(:,:,D));
    
        figure
        plot3(tip(1,:),tip(2,:),tip(3,:));
        hold on
        for jj=1:4
            plot3(ptList{jj}(1,:),ptList{jj}(2,:),ptList{jj}(3,:),'c')
        end
        axis equal
    end
end

%% Register the organ to these fiducial points
fidFolder='R:\Robots\CPD_Reg.git\userstudy_data\FiducialLocations\';
fidLoc=load([fidFolder 'FiducialLocations_1']);
aCT=fidLoc.FidLoc;
basePoints=[baseNew{:}];
[R,t] = rigidPointRegistration(aCT,basePoints(1:3,:));
Micron2CT=transformation(R,t);

arteryFolder='R:\Robots\CPD_Reg.git\userstudy_data\PLY\';
arteryName='Kidney_A_Artery_Pts';
load([arteryFolder arteryName]);
arteryCT=[ptOutput*1000;ones(1,size(ptOutput,2))];

[kidneyReg, points] = registerOrgan(basePoints,1,1);
arteryRob=Micron2CT*arteryCT;
plot3(arteryRob(1,:),arteryRob(2,:),arteryRob(3,:),'x')
plot3(kidneyReg(1,:),kidneyReg(2,:),kidneyReg(3,:),'o')



