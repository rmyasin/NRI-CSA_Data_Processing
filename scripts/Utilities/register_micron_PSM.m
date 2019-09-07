% Find the registration of the dVRK PSM to a base marker seen by the micron
% tracker. Accomplished with rigid registration of end-effector locations
% as measured in both the micron tracker measurements and the dVRK forward
% kinematics

function robot_H_micron = register_micron_PSM(folder,filename,plotOption)
baseLabel=60; %Automatically apply base frame offset using label 60
[cur,des,micron]=readRobTxt(folder,filename,baseLabel); % Read the raw data and apply base offset
a=load('tip_calibration'); % Read tip and marker calibration

tipTotal=getMicronTip(micron,a); % Get Tip Pose

% Find the "settled" times at the end of each robot movement while paused
endIndices=find(diff(abs(sign(diff(des.pos(:,1)))))>0);
desTime=des.time(endIndices);

% Do an interp to find the corresponding times in cur and micron to match
% the times in desTime
micronPos=interp1(tipTotal.time,tipTotal.tip',desTime(2:end));
curMatch=interp1(cur.time,cur.pos,desTime(2:end));

% Register the points of one marker to the matching robot points
[R,t]=rigidPointRegistration(micronPos(:,1:3)',curMatch(:,1:3)');

robot_H_micron=transformation(R,t);

save('robotMicronTransformation','robot_H_micron')

registeredPoints=R*micronPos(:,1:3)'+t;

if plotOption
    %% Plot
    figure
    plot3(curMatch(2:end,1),curMatch(2:end,2),curMatch(2:end,3))
    hold on
    plot3(registeredPoints(1,:),registeredPoints(2,:),registeredPoints(3,:))
    legend('Robot','Micron Tip','Location','North')
    title('Trajectory');
    axis equal
    
    % Plot time plots of path and settled positions
    figure
    plot(des.time,des.pos(1:end,1),'.');
    hold on;plot(desTime,des.pos(endIndices,1),'rx')
    title('Desired Robot position');
    
    figure
    plot(cur.time,cur.pos(:,1:3),'b')
    hold on
    plot(desTime(2:end),curMatch(:,1:3),'rx')
    title('Current Robot position');

    figure
    plot(tipTotal.time,tipTotal.tip)
    hold on
    plot(desTime(2:end),micronPos(:,1:3),'ko')
    title('Micron position');
end