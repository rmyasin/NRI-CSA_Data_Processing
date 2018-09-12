clear
close all
clc

folder='R:\Projects\NRI\User_Study\Data\txtFile\';
filenames={'TestRegA.txt'
            'TestRegA2.txt'
            'TestRegB.txt'};
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

%%
close all

pts{1}=[1325:2500];
pts{2}=[1200:2000];
pts{3}=[3000,3050];

for ii=1:3
    curTip=robot_H_micron*[tipTotal(ii).tip;ones(1,size(tipTotal(ii).tip,2))];
    figure
    plot3(curTip(1,A{ii}),curTip(2,A{ii}),curTip(3,A{ii}),'.');
    hold on
    plot3(curTip(1,B{ii}),curTip(2,B{ii}),curTip(3,B{ii}),'.');
    plot3(curTip(1,C{ii}),curTip(2,C{ii}),curTip(3,C{ii}),'.');
    plot3(curTip(1,D{ii}),curTip(2,D{ii}),curTip(3,D{ii}),'.');
    
    micronRegPts(:,1)=mean(curTip(1:3,A{ii}),2);
    micronRegPts(:,2)=mean(curTip(1:3,B{ii}),2);
    micronRegPts(:,3)=mean(curTip(1:3,C{ii}),2);
    micronRegPts(:,4)=mean(curTip(1:3,D{ii}),2);

    if ii==1 || ii==2
        [kidneyReg, points] = registerOrgan(micronRegPts,1);
    else
        [kidneyReg, points] = registerOrgan(micronRegPts,2);
    end
    
    plot3(kidneyReg(1,:),kidneyReg(2,:),kidneyReg(3,:),'o')
    plot3(curTip(1,pts{ii}),curTip(2,pts{ii}),curTip(3,pts{ii}),'k.');
    plot3(points(1,:),points(2,:),points(3,:),'x','MarkerSize',10)
    axis equal
end

%% Compare tip location to location in robot encoder measurement
% 
figure
for ii=1:3
    curTip=robot_H_micron*[tipTotal(ii).tip;ones(1,size(tipTotal(ii).tip,2))];
    plot3(curTip(1,:),curTip(2,:),curTip(3,:));
    hold on
    plot3(cur(ii).pos(:,1),cur(ii).pos(:,2),cur(ii).pos(:,3),'.');
end
axis equal

