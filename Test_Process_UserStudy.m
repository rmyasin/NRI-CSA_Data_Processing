clear
close all
clc
addpath(genpath(getenv('ARMA_CL')))
addpath(genpath(getenv('ECLDIR')))
cpd_dir=getenv('CPDREG');
organDir=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];


% Create bag objects
VisualBag1=rosbag('user52/Following_Visual_2018-06-25-11-48-26.bag');

%% Look at visual motion
result1=readVisualArteryBag(VisualBag1);


%% Find points of organ and curve
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
plot3(result1.psm_curve(:,1),result1.psm_curve(:,2),result1.psm_curve(:,3))
plot3(kidneyReg(1,:),kidneyReg(2,:),kidneyReg(3,:),'.')

%% Find forces during experiment
% Plot force during path following
figure
plot(result1.ft_curve)

% plot([fMT.fx',fMT.fy',fMT.fz']) %DON"T KNOW WHAT THIS ACTUALLY REPRESENTS


% Camera images? (may need to extract separately a la Colette's code)


