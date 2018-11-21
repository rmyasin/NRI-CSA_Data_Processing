clear
close all
clc
filefolder='R:\Projects\NRI\User_Study\Data\txtFile\';
fileName='MicronRobotTip_Sept19.txt';

% function tipInRobot = endEffectorCalibration(filefolder,fileName)

% Temp for compiling
tipInRobot=zeros(3,1);


plotOption=1;
labelList=[51,52,50,53]; % List order B, C, A, D, base label is B

[cur,des,micron,joint]=readRobTxt(filefolder,fileName);
a=load('tip_calibration'); % Read tip and marker calibration

tipTotal=getMicronTip(micron,a); % Get Tip Pose

% Find the "settled" times at the end of each robot movement while paused
endIndices=find(diff(abs(sign(diff(des.pos(:,1)))))>0);
desTime=des.time(endIndices);

% Do an interp to find the corresponding times in cur and micron to match
% the times in desTime
micronPos=interp1(tipTotal.time,tipTotal.tip',desTime(2:end));
curMatch=interp1(cur.time,cur.pos,desTime(2:end));
jointMatch=interp1(joint.time,joint.q,desTime(2:end));


if plotOption
    % Plot time plots of path and settled positions
    figure
    plot(des.time,des.pos(1:end,1),'.');
    hold on;plot(desTime,des.pos(endIndices,1),'rx')
    title('Desired Robot Position');
    
    figure
    plot(cur.time,cur.pos(:,1:3),'b')
    hold on
    plot(desTime(2:end),curMatch(:,1:3),'rx')
    title('Current Robot Position');

    figure
    plot(tipTotal.time,tipTotal.tip)
    hold on
    plot(desTime(2:end),micronPos(:,1:3),'ko')
    title('Micron Position');
    
    figure
    plot(joint.time,joint.q)
    hold on
    plot(desTime(2:end),jointMatch,'rx')
    title('Joint Position')
end



% end