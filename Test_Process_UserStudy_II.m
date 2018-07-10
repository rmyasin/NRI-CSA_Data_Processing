clear
close all
clc
addpath(genpath(getenv('ARMA_CL')))
addpath(genpath(getenv('ECLDIR')))
cpd_dir=getenv('CPDREG');
organDir=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];

% Bag folder
bagFolder='user52new/';
% Create bag objects
VisualBag=rosbag([bagFolder 'Following_Visual_2018-07-10-09-48-07.bag']);
VFBag=rosbag([bagFolder 'Following_DirectForce_2018-07-10-09-50-05.bag']);
FullVFBag=rosbag([bagFolder 'Following_HybridForce_2018-07-10-09-51-27.bag']);
PalpBag=rosbag([bagFolder 'Palpation_DirectForce_2018-07-10-09-58-43.bag']);
GPBag=rosbag([bagFolder 'Palpation_VisualForce_2018-07-10-09-59-53.bag']);
%% Look at visual motion
result1=readVisualArteryBag(VisualBag1);
BagName=VisualBag;
time_topic = select(BagName, 'Time', [BagName.StartTime BagName.EndTime], 'Topic', '/tf');
output.rawTime=time_topic.MessageList.Time;
output.time=time_topic.MessageList.Time-BagName.StartTime;

psm_cur_topic=select(BagName,'Topic','/dvrk/PSM2/position_cartesian_current','Time', [BagName.StartTime BagName.EndTime]);
psm_des_topic=select(BagName,'Topic','/dvrk/PSM2/position_cartesian_desired','Time', [BagName.StartTime BagName.EndTime]);
mtm_des_topic=select(BagName,'Topic','/dvrk/MTMR/position_cartesian_current','Time', [BagName.StartTime BagName.EndTime]);

ft_topic=select(BagName,'Topic','/dvrk/PSM2_FT/raw_wrench','Time', [BagName.StartTime BagName.EndTime]);
ftpsm_topic=select(BagName,'Topic','/dvrk/PSM2/wrench','Time', [BagName.StartTime BagName.EndTime]);

mtm_wrench_topic=select(BagName,'Topic','/dvrk/MTMR/wrench_body_current','Time', [BagName.StartTime BagName.EndTime]);
mtm_vfwrench_topic=select(BagName,'Topic','/dvrk/MTMR/vf_wrench','Time', [BagName.StartTime BagName.EndTime]);

% Plot robot motion
output.psm_cur=readPoseStampedBag(psm_cur_topic);
output.psm_des=readPoseStampedBag(psm_des_topic);
output.mtm_des=readPoseStampedBag(mtm_des_topic);



% Read wrench bags
ft=readWrenchBag(ft_topic);
ftpsm=readWrenchBag(ftpsm_topic);
fMT=readWrenchBag(mtm_wrench_topic);
fmtm_vf=readWrenchBag(mtm_vfwrench_topic);

% 
lock_orientation_topic=select(BagName,'Topic','/dvrk/MTMR_PSM2/lock_rotation','Time', [BagName.StartTime BagName.EndTime]);
lock_bool=lock_orientation_topic.readMessages;
lock_list=[lock_bool{:}];
locks=[lock_list.Data];
lock_time=lock_orientation_topic.MessageList.Time;
% TODO: MISSING USE OF LOGIC IN locks TO SELECT ELEMENTS OF lock_time


output.psm_curve=trimBetweenTime([output.psm_cur.x',output.psm_cur.y',output.psm_cur.z'],output.psm_cur.time,lock_time);
output.ft_curve=trimBetweenTime([ft.fx',ft.fy',ft.fz'],ft.time,lock_time);
output.fmtm_vf_curve=trimBetweenTime([fmtm_vf.fx',fmtm_vf.fy',fmtm_vf.fz'],fmtm_vf.time,lock_time);

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
plot3(output.psm_curve(:,1),output.psm_curve(:,2),output.psm_curve(:,3))
plot3(kidneyReg(1,:),kidneyReg(2,:),kidneyReg(3,:),'.')

%% Find forces during experiment
% Plot force during path following
figure
plot(result1.ft_curve)

% plot([fMT.fx',fMT.fy',fMT.fz']) %DON"T KNOW WHAT THIS ACTUALLY REPRESENTS


% Camera images? (may need to extract separately a la Colette's code)


