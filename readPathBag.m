function output=readPathBag(varargin)
startTime=varargin{1}.StartTime;

lock_time=[];
for ii=1:nargin
    BagName=varargin{ii};

    time_topic = select(BagName, 'Time', [BagName.StartTime BagName.EndTime], 'Topic', '/tf');
    output.rawTime=time_topic.MessageList.Time;
    output.time=time_topic.MessageList.Time-startTime;
%     psm_cur_topic{ii}=select(BagName,'Topic','/dvrk/PSM2/position_cartesian_current','Time', [BagName.StartTime BagName.EndTime]);
%     psm_des_topic{ii}=select(BagName,'Topic','/dvrk/PSM2/position_cartesian_desired','Time', [BagName.StartTime BagName.EndTime]);
    marker_topic{ii}=select(BagName,'Topic','/micron_markers','Time', [BagName.StartTime BagName.EndTime]);
    
end

% Read robot motion
% output.psm_cur=readPoseStampedBag(psm_cur_topic);
% output.psm_des=readPoseStampedBag(psm_des_topic);
output.mtm_des=readMicronBag(marker_topic);
    
end
