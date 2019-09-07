% Function to return experiment info from a particular folder of a user's data
% % Inputs
% dataFolder - full path to the data folder
% % Outputs
% expOrgan - cell array of organ labels used for each experiment
% expName - data name of each experiment's .txt file
% regTimes - time of most recent organ registration at experiment start
% regNames - name of registration folder containing recent registration

% expOrgan and expName are always 6x1 vectors
%   Index 1: unaided ablation Experiment
%   Index 2: visual ablation Experiment
%   Index 3: direct FB ablation Experiment
%   Index 4: automated FB ablation Experiment
%   Index 5: haptic feedback palpation Experiment
%   Index 6: visual feedback palpation Experiment

function [expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder)
contents=dir(dataFolder);
regTimes=[];
regNames={};

for ii=1:6
    expOrgan{ii}={};
    expName{ii}={};
end

% For each file/folder, save the information to the appropriate variable
for ii=1:length(contents)
    key = contents(ii).name;
    if startsWith(key,'Registration')
        regNames{end+1}=contents(ii).name;
        regTimes(end+1)=str2num(contents(ii).name(14:end));
    elseif startsWith(key,'Following_Visual') && endsWith(key,'.txt')
        organNumber=1;
        start = length('Following_Visual')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{organNumber}= {expOrgan{organNumber}{:},key(start:finish)};
        expName{organNumber}={expName{organNumber}{:},contents(ii).name};
    elseif startsWith(key,'Following_BarVision') && endsWith(key,'.txt')
        organNumber=2;
        start = length('Following_BarVision')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{organNumber}= {expOrgan{organNumber}{:},key(start:finish)};
        expName{organNumber}={expName{organNumber}{:},contents(ii).name};
    elseif startsWith(key,'Following_DirectForce') && endsWith(key,'.txt')
        organNumber=3;
        start = length('Following_DirectForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{organNumber}= {expOrgan{organNumber}{:},key(start:finish)};
        expName{organNumber}={expName{organNumber}{:},contents(ii).name};
    elseif startsWith(key,'Following_HybridForce') && endsWith(key,'.txt')
        organNumber=4;
        start = length('Following_HybridForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{organNumber}= {expOrgan{organNumber}{:},key(start:finish)};
        expName{organNumber}={expName{organNumber}{:},contents(ii).name};
    elseif startsWith(key,'Palpation_DirectForce') && endsWith(key,'.txt')
        organNumber=5;
        start = length('Palpation_DirectForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{organNumber}= {expOrgan{organNumber}{:},key(start:finish)};
        expName{organNumber}={expName{organNumber}{:},contents(ii).name};
    elseif startsWith(key,'Palpation_VisualForce') && endsWith(key,'.txt')
        organNumber=6;
        start = length('Palpation_VisualForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{organNumber}= {expOrgan{organNumber}{:},key(start:finish)};
        expName{organNumber}={expName{organNumber}{:},contents(ii).name};
    end
end

end