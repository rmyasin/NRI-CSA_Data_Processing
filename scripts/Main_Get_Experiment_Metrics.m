clear
close all
clc

restoredefaultpath

% setenv('ARMA_CL','/home/arma/Dev/ACL.git')
% setenv('CPDREG','/home/arma/catkin_ws/src/cpd-registration')
% cpd_dir ='/home/arma/catkin_ws/src/cpd-registration';

saveData=false;
addpath(genpath(getenv('ARMA_CL')))
addpath(genpath('Utilities'))

baseFolder='R:\Projects\NRI\User_Study\Data\VU\user';
arteryExperiments=1:4;
palpationExperiments=5:6;

if saveData
    for userNumber=[2:8,22]
        dataFolder = [baseFolder num2str(userNumber)];
        % Get information about each user's set of experiments
        [expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder);
        
        % Process txt files into matlab and save .mat files of experiment info
        SaveExperimentData(dataFolder,expOrgan,expName,arteryExperiments,palpationExperiments)
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% TODO: actually implement metrics%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

for userNumber=1%%%:8
    dataFolder = [baseFolder num2str(userNumber)];
    % Get information about each user's set of experiments
    [expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder);
    plotOption=false;
    %% Process artery-following experiments
    for ii=arteryExperiments
        metrics{ii}=processArteryExperiment(dataFolder,ii,expOrgan{ii},regTimes,regNames,plotOption);
    end
    
    %% Process palpation experiments
    for ii=palpationExperiments
        metrics{ii}=processPalpationExperiment(dataFolder,ii,expOrgan,regTimes,regNames,plotOption);
    end
end