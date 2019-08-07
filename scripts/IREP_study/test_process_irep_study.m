clear
close all
clc

addpath('R:\Projects\NRI\User_Study\Data_Processing.git\scripts\Utilities')
addpath(genpath(getenv('ARMA_CL')))
saveData=false;


%% Ground truth data
dataFolder = 'R:\Projects\NRI\Force_Sensing\IREP_User_Study\Data\GT';

arteryGT=readRobTxt([dataFolder filesep 'GT_artery_2019-07-16-08-49-06.txt']);
N=100;
[mainVec,center]=fitLine(arteryGT.mag_pos.data');
Vdemean=arteryGT.mag_pos.data'-center;
Omega=mainVec*mainVec';
Vlinear=Omega*Vdemean;
distFromCenter=mainVec'*Vlinear;
arteryPoints=(mainVec.*linspace(min(distFromCenter),max(distFromCenter),N)+center);
save([dataFolder filesep 'GT_artery_2019-07-16'],'arteryPoints');

%% Ablation experiment
dataFolder = 'R:\Projects\NRI\Force_Sensing\IREP_User_Study\Data';

userNumber=0;
fullFolder=[dataFolder filesep 'user' num2str(userNumber)];
contents=dir(fullFolder);
contentsCell={contents.name};
indices=startsWith(contentsCell,'Path_') & endsWith(contentsCell,'.txt');
experimentNames=contentsCell(indices);

if saveData
    for jj=1:length(experimentNames)
        [output]=readRobTxt(fullFolder,experimentNames{jj});
        save([fullFolder filesep experimentNames{jj}(1:end-4) '_processed'],'output');
    end
end

content=dir(fullFolder);
nameList={content.name};
index = startsWith({content.name},'Path_') & endsWith({content.name},'processed.mat');
pathNames=[strcat({content(index).folder},filesep,nameList(index))];
for jj=1:length(pathNames)
    load(pathNames{jj});
    data{jj}=output;
    data{jj}.pathType =str2double(pathNames{jj}(strfind(pathNames{jj},'Path_')+5));
end

%%
addpath('R:\DesignFiles\Matlab Code\yamlmatlab\trunk')
yaml1=ReadYaml('R:\Projects\NRI\Force_Sensing\IREP_User_Study\Data\user0\Path_1_FollowingParams.yaml');
f_desired=yaml1.f_desired;
plotOption=false;
% No feedback
metrics{1}=processArteryIREP(data{1},arteryPoints,plotOption);
% mean(metrics.forceErrorTrue)
% metrics.estimationError
% metrics.estimationError

% FS Feedback
metrics{2}=processArteryIREP(data{2},arteryPoints,plotOption);

% GT Feedback
metrics{3}=processArteryIREP(data{3},arteryPoints,plotOption);

% Useful metric just to have in these experiments measurements of
% estimation error
overallEstimationError=[metrics{1}.forceEstimateVerticalError;metrics{2}.forceEstimateVerticalError;metrics{3}.forceEstimateVerticalError];

%Comparison Metrics
% metrics{ii}.forceErrorTrue; % Force deviation error -increase desired
% force to 1 N!
% metrics{ii}.meanDistance; % Path Following error (should be all the same)
% metrics{ii}.completionTime; % Completion time (should be better when
% having assistance for real users hopefully)

%% String experiments
%% Ablation experiment
dataFolder = 'R:\Projects\NRI\Force_Sensing\IREP_User_Study\Data';
saveData=false;
userNumber=0;
fullFolder=[dataFolder filesep 'user' num2str(userNumber)];
contents=dir(fullFolder);
contentsCell={contents.name};
indices=startsWith(contentsCell,'String_') & endsWith(contentsCell,'.txt');
experimentNames=contentsCell(indices);

if saveData
    for jj=1:length(experimentNames)
        [output]=readRobTxt(fullFolder,experimentNames{jj});
        save([fullFolder filesep experimentNames{jj}(1:end-4) '_processed'],'output');
    end
end

content=dir(fullFolder);
nameList={content.name};
index = startsWith({content.name},'String_') & endsWith({content.name},'processed.mat');
stringNames=[strcat({content(index).folder},filesep,nameList(index))];
for jj=1:length(stringNames)
    load(stringNames{jj});
    data{jj}=output;
end
plotOption=true;
desiredForce=0.75;
metrics{1} = processStringIREP(data{2},desiredForce,plotOption)
metrics{2} = processStringIREP(data{3},desiredForce,plotOption)
metrics{3} = processStringIREP(data{4},desiredForce,plotOption)



figure
plot(data{3}.force_gt.time,data{3}.force_gt.data)
pullTimes=data{3}.buttons.camera.time(logical(data{3}.buttons.camera.push));
vline(pullTimes)
legend('x','y','z')

figure
plot(data{4}.force_gt.time,data{4}.force_gt.data)
pullTimes=data{4}.buttons.camera.time(logical(data{4}.buttons.camera.push));
vline(pullTimes)
legend('x','y','z')
