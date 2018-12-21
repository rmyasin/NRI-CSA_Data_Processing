clear
close all
clc

folder = '/home/mshahba3/catkin_ws/data/micronTrack/';
bagNames={'basePtAPlain_2018-12-16-22-34-53.bag';
        'basePtBPlain_2018-12-16-22-35-50.bag';
        'basePtCPlain_2018-12-16-22-36-54.bag';
        'basePtDPlain_2018-12-16-22-37-39.bag';};

% bagA='basePtA_2018-12-16-22-15-00.txt';
% bagB='basePtB_2018-12-16-22-15-51.txt';
% bagC='basePtC_2018-12-16-22-16-30.txt';
% bagD='basePtD_2018-12-16-22-17-23.txt';

% [cur,des,micron,joint,vProtocol,micronTip]=readRobTxt(/home/mshahba3/catkin_ws/data/micronTip,bagA,)

for ii=1:length(bagNames)
    mybag=rosbag([folder bagNames{ii}]);

    %% Read bag of marker poses during pivot
    time_topic = select(mybag, 'Time', [mybag.StartTime mybag.EndTime], 'Topic', '/tf');
    startTime=mybag.StartTime;
    output.rawTime=time_topic.MessageList.Time;
    output.time=time_topic.MessageList.Time-startTime;
    marker_cur_topic=select(mybag,'Topic','/micron/PROBE_A/measured_cp','Time', [mybag.StartTime mybag.EndTime]);
    output.markerPose=readPoseStampedBag(marker_cur_topic);


    % Calibrate tool based on rotation
    [tip{ii},base{ii},centerPtList{ii}]=calibrateTool([output.markerPose.x;output.markerPose.y;output.markerPose.z]',output.markerPose.R);
    plot3(output.markerPose.x,output.markerPose.y,output.markerPose.z)
    hold on
    plot3(centerPtList{ii}(1,:),centerPtList{ii}(2,:),centerPtList{ii}(3,:))

end


%% Read bag of stationary reference marker, plot movement/sensor jitter
fullBagName='basePtA_2018-12-16-22-33-30.bag'
fullBag=rosbag([folder fullBagName]);

ref = select(fullBag,'Topic','/micron/Ref/measured_cp','Time',[fullBag.StartTime,fullBag.EndTime]);
refPose= readPoseStampedBag(ref);
plot3(refPose.x,refPose.y,refPose.z);


for i=1:length(refPose.R)
    diffR=Rave'*refPose.R(:,:,i);
    axang=rotm2axang(Rave'*refPose.R(:,:,i));
    angleDiffDeg(i)=axang(4)*180/pi;
end
mean(angleDiffDeg)