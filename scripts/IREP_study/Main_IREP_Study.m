clear
close all
clc

addpath('R:\Projects\NRI\User_Study\Data_Processing.git\scripts\Utilities')
addpath(genpath(getenv('ARMA_CL')))
saveData=false;

%% Ground truth data
dataFolder = 'R:\Projects\NRI\User_Study\Data\IREP\GT';
load([dataFolder filesep 'GT_artery_2019-07-16'],'arteryPoints');

%% Get Ablation Data
dataFolder = 'R:\Projects\NRI\User_Study\Data\IREP';
userList=40;
arteryData=getIREPArteryData(dataFolder,userList,saveData);

%% Get Ablation metrics
plotOption=true;

% FS Feedback
for ii=1:length(userList)
    userNumber=userList(ii);
    for jj=1:3
        if arteryData{ii,jj}.pathType ~= jj
            warning('Bad Data at %d, %d',ii,jj)
        end
        arteryMetrics{ii,jj}=processArteryIREP(arteryData{ii,jj},arteryPoints,plotOption);
    end
end

visualError = mean(arteryMetrics{1,1}.forceErrorVert)
fsError = mean(arteryMetrics{1,2}.forceErrorVert)
gtError = mean(arteryMetrics{1,3}.forceErrorVert)

% ES = (visualError-fsError)/std([arteryMetrics{1,1}.forceMeanAppliedVert-0.75,arteryMetrics{1,2}.forceMeanAppliedVert-0.75])
% this applies to a minimum of between 27 (0.9) and 23 (1.0) N, so we'll do
% 5 per user for a total of 40 to be conservative


%% Get String data
% dataFolder = 'R:\Projects\NRI\Force_Sensing\IREP_User_Study\Data\IREP';
% User 30 - new SVR, full experiment
% User 31 - old SVR, just fsense
% User 32 - vertical pulling, just fsense
userList=40; 
% saveData=true;

stringData=getIREPStringData(dataFolder,userList,saveData);
plotOption=true;
for ii=1:size(stringData,1)
    userNumber=userList(ii);
    desiredForce=0.75;

    for jj=1:size(stringData,2)
        stringMetrics{ii,jj} = processStringIREP(stringData{ii,jj},desiredForce,plotOption);
    end
end
% 
VisualError = [stringMetrics{1,1}.rmsPullError]
FSError = [stringMetrics{1,2}.rmsPullError]
GTError = [stringMetrics{1,3}.rmsPullError]

% E/S is around 0.55, requires around N=75, so require 10 pulls (probably
% less would be fine, but why not)

