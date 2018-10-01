clear
close all
clc

folder='R:\Projects\NRI\User_Study\Data\txtFile\';
filenames={'TestRegA.txt'
            'TestRegA2.txt'
            'TestRegB.txt'
            'RegTestSept15.txt'
            'OrganRegNewJSept15.txt'};
%    'TestRegA3.txt % Continuous data, not easy enough to parse, ignored
labelList=[51,52,50,53];

baseLabel=60; %Automatically apply base frame offset using label 60
a=load('tip_calibration'); % Read tip and marker calibration

for ii=1:length(filenames)
    [cur(ii),des(ii),micron]=readRobTxt(folder,filenames{ii},baseLabel); % Read the raw data and apply base offset
    tipTotal(ii)=getMicronTip(micron,a); % Get Tip Pose
end

load('robotMicronTransformation')

%% Test fiducial repeatability between repeated experiments

for ii=1:length(filenames)
    figure(ii)
    curTip=robot_H_micron*[tipTotal(ii).tip;ones(1,size(tipTotal(ii).tip,2))];
    plot3(curTip(1,:),curTip(2,:),curTip(3,:));
    hold on
end
axis equal

%% Find fiducial locations in each experiment
close all
for ii=1:length(filenames)
    figure(ii)
    plot(tipTotal(ii).tip')
    hold on;
    plot((tipTotal(ii).time-mean(tipTotal(ii).time))/10^10*5)
end
A{1}=[1:450];
B{1}=[500:750];
C{1}=[800:1000];
D{1}=[1010:1250];

A{2}=[1:275];
B{2}=[277:450];
C{2}=[500:750];
D{2}=[800:1150];

A{3}=1:400;
B{3}=500:2400;
C{3}=2500:2700;
D{3}=2800:2950;

A{4}=690:820;
B{4}=840:990;
C{4}=1000:1200;
D{4}=1270:1400;

A{5}=790:1100;
B{5}=1150:1450;
C{5}=1460:1700;
D{5}=1740:1900;


pts{1}=[1325:2500];
pts{2}=[1200:2000];
pts{3}=[3000,3050];
pts{4}=[1:600];
pts{5}=[1:730];
%%
close all

tMicron=tipTotal(5).time;
micronPos=tipTotal(5).tip;
tRob=cur(5).time;
robPos=cur(5).pos;
robMatch=interp1(tRob,robPos(:,1:3),tMicron);

plot(robMatch)
%%

% Plot micron locations and registration in robot space
for ii=5%1:length(filenames)
    tMicron=tipTotal(ii).time;
    micronPos=tipTotal(ii).tip;
    tRob=cur(ii).time;
    robPos=cur(ii).pos;
    robMatch=interp1(tRob,robPos(:,1:3),tMicron);
    % Plot stuff
    curTip=robot_H_micron*[tipTotal(ii).tip;ones(1,size(tipTotal(ii).tip,2))];
    figure(ii)
    plot3(curTip(1,A{ii}),curTip(2,A{ii}),curTip(3,A{ii}),'b.');
    hold on
    plot3(curTip(1,B{ii}),curTip(2,B{ii}),curTip(3,B{ii}),'b.');
    plot3(curTip(1,C{ii}),curTip(2,C{ii}),curTip(3,C{ii}),'b.');
    plot3(curTip(1,D{ii}),curTip(2,D{ii}),curTip(3,D{ii}),'b.');
    
    micronRegPts(:,1)=mean(curTip(1:3,A{ii}),2);
    micronRegPts(:,2)=mean(curTip(1:3,B{ii}),2);
    micronRegPts(:,3)=mean(curTip(1:3,C{ii}),2);
    micronRegPts(:,4)=mean(curTip(1:3,D{ii}),2);

    if ii==3
        [kidneyReg, points,HOrgan(:,:,ii)] = registerOrgan(micronRegPts,2);
    else
        [kidneyReg, points,HOrgan(:,:,ii)] = registerOrgan(micronRegPts,1);
    end
    
    plot3(kidneyReg(1,:),kidneyReg(2,:),kidneyReg(3,:),'go')
    plot3(curTip(1,pts{ii}),curTip(2,pts{ii}),curTip(3,pts{ii}),'b.');
    plot3(points(1,:),points(2,:),points(3,:),'x','MarkerSize',10)
    axis equal
    plot3(robMatch(pts{ii},1),robMatch(pts{ii},2),robMatch(pts{ii},3),'r.');
    robMatch=robMatch';
    plot3(robMatch(1,A{ii}),robMatch(2,A{ii}),robMatch(3,A{ii}),'r.');
    plot3(robMatch(1,B{ii}),robMatch(2,B{ii}),robMatch(3,B{ii}),'r.');
    plot3(robMatch(1,C{ii}),robMatch(2,C{ii}),robMatch(3,C{ii}),'r.');
    plot3(robMatch(1,D{ii}),robMatch(2,D{ii}),robMatch(3,D{ii}),'r.');

end

%%
% Compare tip location to location in robot encoder measurement
for ii=1:length(filenames)
    figure(ii)
    hold on
    plot3(cur(ii).pos(:,1),cur(ii).pos(:,2),cur(ii).pos(:,3),'.');
end
axis equal

