clear
close all
clc


saveData=false;

baseFolder='R:\Projects\NRI\User_Study\Data\VU\user';
arteryExperiments=1:4;
palpationExperiments=5:6;

if saveData
    for userNumber=1:8 %#ok<UNRCH>
        dataFolder = [baseFolder num2str(userNumber)];
        % Get information about each user's set of experiments
        [expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder);
        
        % Process txt files into matlab and save .mat files of experiment info
        SaveExperimentData(dataFolder,expOrgan,expName,arteryExperiments,palpationExperiments)
    end
end

%% Process experiments

for userNumber=1:8
    dataFolder = [baseFolder num2str(userNumber)];
    % Get information about each user's set of experiments
    [expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder);
    
    plotOption=true;
    %% Process artery-following experiments
    for ii=arteryExperiments
        arteryMetrics(userNumber,ii)=processArteryExperiment(dataFolder,ii,expOrgan{ii},regTimes,regNames,plotOption,0);
    end
    
    %% Process palpation experiments
    for ii=palpationExperiments
        if size(expOrgan{ii})~=4
            error('Incorrect number of experiments, change the data');
        end
        palpationMetrics(userNumber,ii-4)=processPalpationExperiment(dataFolder,ii,expOrgan,regTimes,regNames,plotOption);
    end
end

%% Plot statistics
plotArteryStatistics(arteryMetrics)
save('arteryMetrics','arteryMetrics')

plotPalpationStatistics(palpationMetrics)
save('palpationMetrics','palpationMetrics')
