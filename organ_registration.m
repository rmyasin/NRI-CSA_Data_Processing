% Inputs:
% dataFolder:
% filenames: 
% organNumbers: 1-indexed, 1=organ A, 2= organ B, 3=...
% regTimes: a struct with
function HOrgan=organ_registration(dataFolder,filenames,organNumbers,regTimes)
if ~iscell(filenames)
    filenames={filenames};
end
baseLabel=60; %Automatically apply base frame offset using label 60
a=load('tip_calibration'); % Read tip and marker calibration

for ii=length(filenames):-1:1
    [cur(ii),~,micron]=readRobTxt(dataFolder,filenames{ii},baseLabel); % Read the raw data and apply base offset
    tipTotal(ii)=getMicronTip(micron,a); % Get Tip Pose
end

load('robotMicronTransformation') % load robot_H_micron


%%

% Plot micron locations and registration in robot space
for ii=1:length(filenames)
    tMicron=tipTotal(ii).time;
    tRob=cur(ii).time;
    robPos=cur(ii).pos;
    robMatch=interp1(tRob,robPos(:,1:3),tMicron);
    
    curTip=robot_H_micron*[tipTotal(ii).tip;ones(1,size(tipTotal(ii).tip,2))];
    
    micronRegPts(:,1)=mean(curTip(1:3,regTimes(ii).A),2);
    micronRegPts(:,2)=mean(curTip(1:3,regTimes(ii).B),2);
    micronRegPts(:,3)=mean(curTip(1:3,regTimes(ii).C),2);
    micronRegPts(:,4)=mean(curTip(1:3,regTimes(ii).D),2);

    [kidneyReg, points,HOrgan(:,:,ii)] = registerOrgan(micronRegPts,organNumbers(ii));

    % Plot stuff
    figure(ii)
    plot3(curTip(1,regTimes(ii).A),curTip(2,regTimes(ii).A),curTip(3,regTimes(ii).A),'b.');
    hold on
    plot3(curTip(1,regTimes(ii).B),curTip(2,regTimes(ii).B),curTip(3,regTimes(ii).B),'b.');
    plot3(curTip(1,regTimes(ii).C),curTip(2,regTimes(ii).C),curTip(3,regTimes(ii).C),'b.');
    plot3(curTip(1,regTimes(ii).D),curTip(2,regTimes(ii).D),curTip(3,regTimes(ii).D),'b.');

    plot3(kidneyReg(1,:),kidneyReg(2,:),kidneyReg(3,:),'go')
    plot3(curTip(1,regTimes(ii).pts),curTip(2,regTimes(ii).pts),curTip(3,regTimes(ii).pts),'b.');
    plot3(points(1,:),points(2,:),points(3,:),'x','MarkerSize',10)
    axis equal
    plot3(robMatch(regTimes(ii).pts,1),robMatch(regTimes(ii).pts,2),robMatch(regTimes(ii).pts,3),'r.');
    robMatch=robMatch';
    plot3(robMatch(1,regTimes(ii).A),robMatch(2,regTimes(ii).A),robMatch(3,regTimes(ii).A),'r.');
    plot3(robMatch(1,regTimes(ii).B),robMatch(2,regTimes(ii).B),robMatch(3,regTimes(ii).B),'r.');
    plot3(robMatch(1,regTimes(ii).C),robMatch(2,regTimes(ii).C),robMatch(3,regTimes(ii).C),'r.');
    plot3(robMatch(1,regTimes(ii).D),robMatch(2,regTimes(ii).D),robMatch(3,regTimes(ii).D),'r.');
end
