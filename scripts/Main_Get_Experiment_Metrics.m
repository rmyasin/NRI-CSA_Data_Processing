clear
close all
clc

restoredefaultpath
addpath(genpath(getenv('ARMA_CL')))
addpath(genpath('Utilities'))

dataFolder='R:\Projects\NRI\User_Study\Data\user22';
% dataFolder='R:\Projects\NRI\User_Study\Data\user12';
plotOption=true;
% cpd_dir ='/home/arma/catkin_ws/src/cpd-registration';

[expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder);

%% TODO test one more time with "palpation on" rostopic
arteryExperiments=1:4;
palpationExperiments=5:6;
% SaveExperimentData(dataFolder,expOrgan,expName,arteryExperiments,palpationExperiments)

% TODO: actually implement metrics

%% Process artery-following experiments
for ii=arteryExperiments
    metrics{ii}=processArteryExperiment(dataFolder,ii,expOrgan{ii},regTimes,regNames,plotOption);
end

%% Process palpation experiments
for ii=5:6
    metrics{ii}=processPalpationExperiment(dataFolder,ii,expOrgan,regTimes,regNames,plotOption);
end
