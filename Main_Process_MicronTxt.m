clear
close all
clc

folder='R:\Projects\NRI\User_Study\Data\txtFile\';
robfile=fopen([folder 'MicronMoveI.txt']);
titleList={'psm_cur','psm_des','micron'};
line=fgetl(robfile);

cur.time=[];
cur.pos=[];
des.time=[];
des.pos=[];
micron.time=[];
micron.dat=[];

while line~=-1
    temp=find(strcmp(line,titleList));
    if temp
        typeIndex=temp;
    else
        numLine=str2num(line);
        switch typeIndex
            case 1
                cur.time=[cur.time;numLine(1)];
                cur.pos=[cur.pos;numLine(2:end)];
            case 2
                des.time=[des.time;numLine(1)];
                des.pos=[des.pos;numLine(2:end)];
            case 3
                micron.time=[micron.time;numLine(1)];
                micron.dat=[micron.dat;numLine(2:end)];
        end
    end
    line=fgetl(robfile);
end

fclose(robfile);

figure
plot(micron.time-micron.time(1),micron.dat(:,1:3));
hold on

figure
plot(cur.time-cur.time(1),cur.pos(:,1:3));
hold on
figure
plot(des.time-cur.time(1),des.pos(:,1),'.');

%%
close all
plot(des.time,des.pos(1:end,1),'.');
hold on
% plot(abs(sign(diff(des.pos(:,1)))),'.');
% hold on
% plot(diff(abs(sign(diff(des.pos(:,1)))))<0,'bx');
endIndices=find(diff(abs(sign(diff(des.pos(:,1)))))>0);
desTime=des.time(endIndices);
hold on;plot(desTime,des.pos(endIndices,1),'rx')

% Do an interp to find the corresponding times in cur and micron to match
% the times in desTime
micronMatch=interp1(micron.time,micron.dat,des.time);
curMatch=interp1(cur.time,cur.pos,des.time);

figure
plot(cur.time,cur.pos(:,1:3),'b')
hold on
plot(desTime,curMatch(endIndices,1:3),'rx')
figure
plot(micron.time,micron.dat(:,1:3))
hold on
plot(desTime,micronMatch(endIndices,1:3),'ko')


%% Now we have settled data for current, des, and micron (101 poses)
% 0) Add a base marker so that moving the tracker won't break everything
% 1) Find the tool tip using a calibration of the tip using the
% microntracker
%    1A) Note this is offset from the gripper - change the .json
%     we are using to match this new tool definision (good practice anyway)
%    1B) Check the dVRK kinematics for gripper location, see if we need to
%    change the probe location for the other things as well. May want to
%    just roll around an arbitrary point and see how much position changes
%    and see if that means the json needs adjusting for ee offset.
% 2) Now we have pointclouds that *should* match, don't need to solve the
% hand-eye. We can do a rigid registration to find the correspondence
% between the robot/micron frames.
% 3) With the registered point clouds, re-run the experiment a couple of
% times and see if there is a significant change or robot location with
% different homing.
% 4) Can also look at doing a rotation experiment in a pivot while
% recording data with the robot clutched. Does the tip move significantly?
% THIS MAY BE A JSON THING!!!


%%
centeredMicron=micron.dat-mean(micron.dat);
centeredRob=cur.pos-mean(cur.pos);

figure
plot3(centeredMicron(:,1),centeredMicron(:,2),centeredMicron(:,3))
hold on
plot3(centeredRob(:,1),centeredRob(:,2),centeredRob(:,3))
