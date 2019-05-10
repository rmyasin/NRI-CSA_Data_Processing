clear
close all
clc

restoredefaultpath

setenv('ARMA_CL','/home/arma/Dev/ACL.git')
setenv('CPDREG','/home/arma/catkin_ws/src/cpd-registration')



addpath(genpath(getenv('ARMA_CL')))
addpath(genpath('Utilities'))

% dataFolder='R:\Projects\NRI\User_Study\Data\user22';
% dataFolder='/home/arma/catkin_ws/data/JHU/user20';
dataFolder='/home/arma/catkin_ws/data/user77';
% dataFolder='/home/arma/catkin_ws/data/CMU/user1';
% dataFolder='R:\Projects\NRI\User_Study\Data\user12';
plotOption=true;
% cpd_dir ='/home/arma/catkin_ws/src/cpd-registration';

[expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder);

%% TODO test one more time with "palpation on" rostopic
arteryExperiments=2:4;
palpationExperiments=5:6;
SaveExperimentData(dataFolder,expOrgan,expName,arteryExperiments,palpationExperiments)

% TODO: actually implement metrics

%% Process artery-following experiments
for ii=arteryExperiments
    metrics{ii}=processArteryExperiment(dataFolder,ii,expOrgan{ii},regTimes,regNames,plotOption);
end

%% Process palpation experiments
for ii=palpationExperiments
    metrics{ii}=processPalpationExperiment(dataFolder,ii,expOrgan,regTimes,regNames,plotOption);
end
