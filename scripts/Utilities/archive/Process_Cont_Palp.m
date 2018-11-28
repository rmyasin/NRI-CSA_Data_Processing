clear
close all
clc

addpath(genpath(getenv('ARMA_CL')))
addpath(genpath(getenv('ECLDIR')))
cpd_dir=getenv('CPDREG');
organDir=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];
addpath(genpath('R:\Robots\CPD_Reg.git\userstudy_data\'))
% Bag folder
bagFolder='continuous_palpation/';

%% Get data
newdata=0;
if newdata
    % Create bag objects
    PalpBag=rosbag([bagFolder 'cont_palp_v2_2018-07-30-11-27-40_0.bag']);
    PalpBag1=rosbag([bagFolder 'cont_palp_v2_2018-07-30-11-31-40_1.bag']);
    PalpBag2=rosbag([bagFolder 'cont_palp_v2_2018-07-30-11-35-40_2.bag']);
    % Palpation output
    palpout=readContinuousBag(PalpBag);
    palpout1=readContinuousBag(PalpBag1);
    palpout2=readContinuousBag(PalpBag2);

    save('Cont_Palp_out','palpout','palpout1','palpout2');
else
    load ('Cont_Palp_out')
end
%% Find points of organ and curve
load('VF_out')
% Find registration
HOrgan=readTxtReg([bagFolder 'PSM2Phantom.txt']);

% Load Organ and register to robot frame
temp=load([organDir filesep 'Kidney_A_iter_100_NoOpt.mat']);
kidneyPointsRaw=temp.T.Y'/1000;
clear('temp');
kidneyHomog=[kidneyPointsRaw;ones(1,size(kidneyPointsRaw,2))];
kidneyReg=HOrgan*kidneyHomog;

%Load curve
arteryDir=[cpd_dir filesep 'userstudy_data' filesep 'PLY'];
temp=load([arteryDir filesep 'Kidney_A_Artery_Pts.mat']);
arteryPointsRaw=temp.ptOutput;
clear('temp');
arteryHomog=[arteryPointsRaw;ones(1,size(arteryPointsRaw,2))];
arteryReg=HOrgan*arteryHomog;

% Plot Curve, organ, and exploration path
figure
plot3(arteryReg(1,:),arteryReg(2,:),arteryReg(3,:))
hold on
plot3(palpout.psm_cur.x(:),palpout.psm_cur.y(:),palpout.psm_cur.z(:))
plot3(palpout.psm_des.x(:),palpout.psm_des.y(:),palpout.psm_des.z(:))
plot3(kidneyReg(1,:),kidneyReg(2,:),kidneyReg(3,:),'.')

figure
plot(palpout.ft.fx(:))
hold on
plot(palpout.ft.fy(:))
plot(palpout.ft.fz(:));
% plot3(palpout.psm_grip.x,palpout.psm_grip.y,palpout.psm_grip.z,'r*')

