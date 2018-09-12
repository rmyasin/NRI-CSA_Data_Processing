% Find the registration of the dVRK PSM to a base marker seen by the micron
% tracker. Accomplished with rigid registration of end-effector locations
% as measured in both the micron tracker measurements and the dVRK forward
% kinematics

clear
close all
clc

folder='R:\Projects\NRI\User_Study\Data\txtFile\';
% filename='MicronRobRegSept8.txt';
filename='MicronRobRegSept12.txt';


labelList=[51,52,50,53];

baseLabel=60; %Automatically apply base frame offset using label 60
[cur,des,micron]=readRobTxt(folder,filename,baseLabel); % Read the raw data and apply base offset
a=load('tip_calibration'); % Read tip and marker calibration

% TODO: default to preferred frames for readings at the same frame of the
% micron tracker
% TODO: make sure that *all* markers have relatively reasonable rotation
% calibrations (tip calibration seems ok from tip experiment)
tipTotal=getMicronTip(micron,a); % Get Tip Pose
save('RegistrationWorkspace')

%%
load('RegistrationWorkspace')
% Find the "settled" times at the end of each robot movement while paused
endIndices=find(diff(abs(sign(diff(des.pos(:,1)))))>0);
desTime=des.time(endIndices);

% Do an interp to find the corresponding times in cur and micron to match
% the times in desTime
micronPos=interp1(tipTotal.time,tipTotal.tip',desTime(2:end));
% micron53Match=interp1(tipTotal.time(tipTotal.label==53),tipTotal.tip(:,tipTotal.label==53)',des.time);
curMatch=interp1(cur.time,cur.pos,desTime(2:end));

% Register the points of one marker to the matching robot points
[R,t]=rigidPointRegistration(micronPos(:,1:3)',curMatch(:,1:3)');

robot_H_micron=transformation(R,t);

save('robotMicronTransformation','robot_H_micron')

registeredPoints=R*micronPos(:,1:3)'+t;

%% Read the path following data
filename='Follow1Sept12.txt';
[cur1,des1,micron1]=readRobTxt(folder,filename,baseLabel); % Read the raw data and apply base offset
tipFollow1=getMicronTip(micron1,a); % Get Tip Pose
endIndices1=find(diff(abs(sign(diff(des1.pos(:,1)))))>0);
desTime1=des1.time(endIndices1);
desPos1=des1.pos(endIndices1,1:3);
micronPos1=interp1(tipFollow1.time,tipFollow1.tip',desTime1(2:end));
curMatch1=interp1(cur1.time,cur1.pos,desTime1(2:end));

micronPos1=(R*micronPos1'+t)';
micronPos2=(R*micronPos2'+t)';
filename='Follow2Sept12.txt';
[cur2,des2,micron2]=readRobTxt(folder,filename,baseLabel); % Read the raw data and apply base offset
tipFollow2=getMicronTip(micron2,a); % Get Tip Pose
endIndices2=find(diff(abs(sign(diff(des2.pos(:,1)))))>0);
desTime2=des2.time(endIndices2);
desPos2=des2.pos(endIndices2,1:3);
micronPos2=interp1(tipFollow2.time,tipFollow2.tip',desTime2(2:end));
curMatch2=interp1(cur2.time,cur2.pos,desTime2(2:end));
close all
figure % Exact match in desired position
plot3(desPos1(3:end,1),desPos1(3:end,2),desPos1(3:end,3))
hold on
plot3(desPos2(3:end,1),desPos2(3:end,2),desPos2(3:end,3),'.')

figure
plot3(curMatch1(3:end,1),curMatch1(3:end,2),curMatch1(3:end,3))
hold on
plot3(curMatch2(3:end,1),curMatch2(3:end,2),curMatch2(3:end,3))
encoderError=mean(sqrt(sum((curMatch1(3:end,:)-curMatch2(3:end,:)).^2,2)));
plot3(micronPos1(3:end,1),micronPos1(3:end,2),micronPos1(3:end,3),'--')
hold on
plot3(micronPos2(3:end,1),micronPos2(3:end,2),micronPos2(3:end,3),'--')
micronError=mean(sqrt(sum((micronPos1(3:end,:)-micronPos2(3:end,:)).^2,2)));
legend('Encoder Exp 1','Encoder Exp 2','Micron Exp 1','Micron Exp 2')


%% Plot stuff
figure
plot3(curMatch(2:end,1),curMatch(2:end,2),curMatch(2:end,3))
hold on
plot3(registeredPoints(1,:),registeredPoints(2,:),registeredPoints(3,:))
legend('Robot','Marker Tip','Location','North')
axis equal

% Plot time plots of path and settled positions
figure
plot(des.time,des.pos(1:end,1),'.');
hold on;plot(desTime,des.pos(endIndices,1),'rx')
figure
plot(cur.time,cur.pos(:,1:3),'b')
hold on
plot(desTime(2:end),curMatch(:,1:3),'rx')
figure
plot(tipTotal.time,tipTotal.tip)
hold on
plot(desTime(2:end),micronPos(:,1:3),'ko')
% plot(desTime,micron53Match(:,1:3),'rx')
%% Plot rotations of all frames
% close all
% lab1=tipTotal.label==50;
% lab2=tipTotal.label==53;
% 
% figure
% for ii=1:3
%     for jj=1:3
%         plot(tipTotal.frame(:),squeeze(tipTotal.rot(ii,jj,:)))
%         hold on
%     end
% end
% figure
% for ii=1:3
%     for jj=1:3
%         plot(tipTotal.frame(lab1),squeeze(tipTotal.rot(ii,jj,lab1)))
%         hold on
%     end
% end
% figure
% for ii=1:3
%     for jj=1:3
%         plot(tipTotal.frame(lab2),squeeze(tipTotal.rot(ii,jj,lab2)))
%         hold on
%     end
% end