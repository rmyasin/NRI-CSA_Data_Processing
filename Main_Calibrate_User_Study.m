% Overview
% Methods needed for using micron optical tracker 

% Required repositories
% % % % % % % % % % % % % % % % % % % % % % % % % % 
% Continuous palpation: 
% Processing: 
% % % % % % % % % % % % % % % % % % % % % % % % % % 

% Data Collection
% During each experiment, "roslaunch continuous_palpation path_following.launch filename:=bagNameToSave"

% Data Processing
% After an experiment has been run, run "micron_processing.py" and change
% the bagname and filename for the output (lines ### and ####)

% Step 0: Physical Setup
% -Make sure force sensor is set somewhere rigidly and attached to the new
% holder plate that will keep the organs in place repeatably
% -Print (paper) an extra (large) micron marker and attach it somewhere in
% the workspace where it won't move relative to the force sensor
% -3D print the micron probe attachment, and glue ABCD paper-printed micron
% markers to the 4 faces so, looking from the top, they look like:
%  ---B---
% |       |
% D       C
% |       |
%  ---A---
% For consistency, have the short "vector" of the marker point away from
% the tip

clear
close all
clc

dataFolder='R:\Projects\NRI\User_Study\Data\txtFile\';

%% Step 1: Micron Calibration
% Perform pivot calibration and find relative transforms between the
% markers on the micron probe attachment, must pivot each face in a divot
% and save frames that show each pair of adjacent markers
pivotFilename='MicronTipCalib_Sept7.txt';
% % % % 
% NOTE: there's a workaround at line 83 for data corruption at VU
% % % % 
tip_calibration = pivot_calibration_micron(dataFolder ,pivotFilename);
% This also saves the tip calibration to "tip_calibration"


%% Step 2A: Find the offset of the microntracker markers from the robot kinematics
% micron_robot_tip='MicronRobotTip_Sept19.txt';
% 
% tipInRobot = endEffectorCalibration(dataFolder,micron_robot_tip);
% % When step 2A is done, update the local json file with the tip offset
% % according to the robot kinematics
% % For example, at VU, this looks like: 

%% Step 2: Register the micron tracker to the robot




% % % % % % % % % % % % % % % % % 
% TODO: LINK CODE FOR RASTER SCAN TO REGISTER ROBOT
% % % % % % % % % % % % % % % % % 

% Main_Micron2Rob_Registration
micron2robFilename='RobRegNewJSept15.txt';
plotOption=1;
robot_H_micron = register_micron_PSM(dataFolder, micron2robFilename,plotOption);
% This also saves the registration to "robotMicronTransformation"

%% Step 3: Register the organ to robot frame
% Launch path following, but don't send a trajectory
% Clutch the robot to each corner (A,B,C,D) in order, while collecting
% micron data
organFilenames={'OrganRegNewJSept15.txt';
                'RegOrganBSept16.txt'};
organNumbers=[1,2];
% DO ANOTHER ONE OF THESE WITH THE OTHER ORGAN JUST TO SHOW HOW IT WORKS,
% EVEN THOUGH IT'S NOT NECESSARY

% % % % % % % % 
% % Run this 1x per experiment to pick the times when you are at each 
% fiducial point during the experiment
% plotExperiment(dataFolder,organFilenames);
% % % % % % % % 

regTimes(1).pts=1:730;
regTimes(1).A=790:1100;
regTimes(1).B=1150:1450;
regTimes(1).C=1460:1700;
regTimes(1).D=1740:1900;

regTimes(2).pts=[1,200];
regTimes(2).A=230:500;
regTimes(2).B=502:640;
regTimes(2).C=650:800;
regTimes(2).D=820:1000;

HOrgan=organ_registration(dataFolder, organFilenames,organNumbers,regTimes);

%% Test registration of all organs with a particular set of points - 
% given the force sensor fixture, should not need to do this experiment 2x
micronRegPts1 =[ 3.4219  -46.2906  -41.3666    8.3906
                -69.9199  -68.1987   85.2324   83.7160
                -205.2978 -204.5542 -196.5230 -197.6915];

micronRegPts2 =[4.0547  -46.9320  -42.1599    7.9371
                -69.1075  -68.1532   85.3465   83.7426
                -205.6325 -203.6988 -196.5033 -197.4037];
meanRegPts=(micronRegPts1+micronRegPts2)/2;
for ii=1:6
    [~,~,HTest(:,:,ii)]=registerOrgan(meanRegPts,ii);
end