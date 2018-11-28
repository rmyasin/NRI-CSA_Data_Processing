% clear
% close all
% clc
addpath(genpath(getenv('ARMA_CL')))
addpath(genpath(getenv('ECLDIR')))
cpd_dir=getenv('CPDREG');
organDir=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];
addpath(genpath('R:\Robots\CPD_Reg.git\userstudy_data\'))
% Bag folder
bagFolder='user1/';
bagFolder='user14_Nabil_testablate/'
% Create bag objects

%%
VisualBag=rosbag([bagFolder 'Following_Visual_2018-07-30-11-00-23_0.bag']);
VFBag=rosbag([bagFolder 'Following_DirectForce_2018-07-30-11-01-55_0.bag']);
FullVFBag=rosbag([bagFolder 'Following_HybridForce_2018-07-30-11-03-12_0.bag']);
PalpBag=rosbag([bagFolder 'Palpation_DirectForce_2018-07-30-11-04-50_0.bag']);
GPBag=rosbag([bagFolder 'Palpation_VisualForce_2018-07-30-11-05-44_0.bag']);

bagFolder='user1/';
%% Look at visual motion
output=readVisualArteryBag(VisualBag);
output2=readVisualArteryBag(VFBag);
output3=readVisualArteryBag(FullVFBag);
save('VF_out','output','output2','output3')

%% Palpation output
palpout=readPalpationBag(PalpBag);
GPpalpout=readGPPalpationBag(GPBag);

save('Palp_out','palpout','newpalpout');
%% Find points of organ and curve
load('VF_out')
% Find registration
HOrgan=readTxtReg('user52/PSM2PhantomReg_UserStudy.txt');

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

% Plot Curve (a priori and experimental) and organ
plot3(arteryReg(1,:),arteryReg(2,:),arteryReg(3,:))
hold on
plot3(output.psm_curve(:,1),output.psm_curve(:,2),output.psm_curve(:,3))
plot3(output2.psm_curve(:,1),output2.psm_curve(:,2),output2.psm_curve(:,3))
plot3(output3.psm_curve(:,1),output3.psm_curve(:,2),output3.psm_curve(:,3))
plot3(kidneyReg(1,:),kidneyReg(2,:),kidneyReg(3,:),'.')

plot3(palpout.psm_grip.x,palpout.psm_grip.y,palpout.psm_grip.z,'r*')


%% Kidney B
load('Palp_out');

sphereDir=[cpd_dir filesep 'userstudy_data' filesep 'PLY'];
temp=load([sphereDir filesep 'Kidney_B_Sphere_Pts.mat']);
spherePointsRaw=temp.ptOutput;
clear('temp');
sphereHomog=[spherePointsRaw;ones(1,size(spherePointsRaw,2))];
sphereReg=HOrgan*sphereHomog;

% HOrgan=readTxtReg('user53/PSM2PhantomReg_UserStudy.txt');
% HOrgan=readTxtReg('user53/testPSM2Phantom.txt');
robPosns=[0.0138716380604 -0.0353429420436 -0.0351697119807 0.0115195207286
     	-0.0618899405864 -0.064376841522 0.0862448993117 0.0883603120564
    	-0.182638550176 -0.181607703424 -0.178479708829 -0.178706222603];
b=load('FiducialLocations_2');
b.FidLoc=b.FidLoc/1000

[R,t]=rigidPointRegistration(b.FidLoc,robPosns);
HOrgan=transformation(R,t);


% Load Organ and register to robot frame
temp=load([organDir filesep 'Kidney_B_iter_100_NoOpt.mat']);
kidneyPointsRaw=temp.T.Y'/1000;
clear('temp');
kidneyHomog=[kidneyPointsRaw;ones(1,size(kidneyPointsRaw,2))];
kidneyReg=HOrgan*kidneyHomog;
plot3(kidneyReg(1,:),kidneyReg(2,:),kidneyReg(3,:),'.')
hold on
plot3(newpalpout.psm_grip.x,newpalpout.psm_grip.y,newpalpout.psm_grip.z,'r*')
plot3(sphereReg(1,:),sphereReg(2,:),sphereReg(3,:),'ko')

%% Find forces during experiment
% Plot force during path following
figure
plot(output.ft_curve)
hold on
plot(output2.ft_curve)
plot(output3.ft_curve)

% plot([fMT.fx',fMT.fy',fMT.fz']) %DON"T KNOW WHAT THIS ACTUALLY REPRESENTS
% Camera images? (may need to extract separately a la Colette's code)
