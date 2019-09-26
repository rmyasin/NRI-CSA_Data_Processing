clear
close all
% clc

organ_reg_pts;
organLabel='A';
x=organFids0;
[rob,mic]=readPSMRegPts('.','PSMRegPtsVU.txt');

y=[mean(rob.pos{1})', mean(rob.pos{2})', mean(rob.pos{3})' , mean(rob.pos{4})'];
yMicron=[mean(mic.pos{1})', mean(mic.pos{2})', mean(mic.pos{3})' , mean(mic.pos{4})'];

[R,t]=rigidPointRegistration(x,y);
FLE = mean(colNorm(y-(R*x+t))); %in meters

%     0.0023
[R2,t2]=rigidPointRegistration(x,yMicron);
FLE_micron = mean(colNorm(yMicron-(R2*x+t2))); %in meters
% 4.3504e-04

cpd_dir=getenv('CPDREG');
featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];

fclose('all');

temp=load([featureFolder filesep 'Kidney_' organLabel '_Artery_Pts.mat']);
arteryPointsRaw=temp.ptOutput;
clear('temp');

vplot3(x')
hold on
vplot3(arteryPointsRaw')

%%
% TRE calculation along artery
TRE_RMS = mean(treapprox(x,arteryPointsRaw,FLE))

TRE_RMS_Micron = mean(treapprox(x,arteryPointsRaw,FLE_micron))

% Mean TRE is 1.9mm with robot, 0.4 mm with micron
