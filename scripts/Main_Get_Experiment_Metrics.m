clear
close all
clc

saveData=false;
plotOption=false;

% baseFolder='R:\Projects\NRI\User_Study\Data\VU\user';
% baseFolder='R:\Projects\NRI\User_Study\Data\JHU\user';
% baseFolder='R:\Projects\NRI\User_Study\Data\CMU\user';
baseFolder='R:\Projects\NRI\User_Study\Data\combined\user';
arteryExperiments=1:4;
palpationExperiments=5:6;
userList=[1:16,19:26]; %All data
% userList=1:8; %VU data
% userList=9:16; %JHU data
% userList=17:26; %CMU %users 17 and 18 are less good :(
% userList=25;
% load('arteryMetrics')

if saveData
    for userNumber=userList %#ok<UNRCH>
        dataFolder = [baseFolder num2str(userNumber)];
        % Get information about each user's set of experiments
        
        %CMU DATA problems
        if userNumber==17
            arteryExperiments=[1:2,4];
        elseif userNumber==18
            arteryExperiments=1:2;
        else
            arteryExperiments=1:4;
        end
        
        [expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder);
        
        % Process txt files into matlab and save .mat files of experiment info
        SaveExperimentData(dataFolder,expOrgan,expName,arteryExperiments,palpationExperiments)
    end
end

%% Process experiments
for userNumber=userList
    dataFolder = [baseFolder num2str(userNumber)];
    % Get information about each user's set of experiments
    [expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder);
    
    %CMU data manual fixes for missing datasets or mislabelled organs
    if userNumber==17
        arteryExperiments=[1:2,4];
    elseif userNumber==18
        arteryExperiments=1:2;
        expOrgan{5}{3}='21';
    elseif userNumber==20 
        expOrgan{6}{4}='21';
    elseif userNumber==25
        expOrgan{6}{4}='21';
    elseif userNumber==26
        expOrgan{6}{1}='11';
    else
        arteryExperiments=1:4;
    end
    
    %% Process artery-following experiments
    for ii=arteryExperiments
%             disp(['Data Folder: ' dataFolder]);
%             disp(['Experiment ' num2str(ii)]);
            arteryMetrics(userNumber,ii)=processArteryExperiment(dataFolder,ii,expOrgan{ii}{1},regTimes,regNames,plotOption,0,userNumber);
    end
    
    %% Process palpation experiments
    for ii=palpationExperiments
        if size(expOrgan{ii})~=4
             warning('Incorrect number of experiments, change the data');
        end
        palpationMetrics(userNumber,ii-4)=processPalpationExperiment(dataFolder,ii,expOrgan,regTimes,regNames,plotOption,userNumber);
    end
end

%% Plot statistics
% load('arteryMetrics')
plotArteryStatistics(arteryMetrics)
% save('arteryMetrics','arteryMetrics')

% load('palpationMetrics')
plotPalpationStatistics(palpationMetrics)
% save('palpationMetrics','palpationMetrics')
