function output=readPalpationBag(PalpBag,plotoption)
if nargin<2
    plotoption=1;
end

% grip_close_topic=select(PalpBag,'Topic','/dvrk/MTMR/gripper_closed_event','Time', [PalpBag.StartTime PalpBag.EndTime]);
% grip_close_read=grip_close_topic.readMessages;
% grip_close_time=grip_close_topic.MessageList.Time;
% grip_close_list=[grip_close_read{:}];
% grip_close=[[grip_close_list.Data]',grip_close_time];


grip_pinch_topic =  select(PalpBag,'Topic','/dvrk/MTMR/gripper_pinch_event','Time', [PalpBag.StartTime PalpBag.EndTime]);
psm_cur_topic =     select(PalpBag,'Topic','/dvrk/PSM2/position_cartesian_current','Time', [PalpBag.StartTime PalpBag.EndTime]);
psm_des_topic =     select(PalpBag,'Topic','/dvrk/PSM2/position_cartesian_desired','Time', [PalpBag.StartTime PalpBag.EndTime]);
ft_topic =          select(PalpBag,'Topic','/dvrk/PSM2_FT/raw_wrench','Time', [PalpBag.StartTime PalpBag.EndTime]);

grip_pinch_time=grip_pinch_topic.MessageList.Time;

output.psm_cur=readPoseStampedBag(psm_cur_topic);
output.psm_des=readPoseStampedBag(psm_des_topic);
output.ft=readWrenchBag(ft_topic);

[~,timeIn]=min(abs(repmat(output.psm_cur.time,1,length(grip_pinch_time))-grip_pinch_time'));
output.psm_grip.x=output.psm_cur.x(timeIn);
output.psm_grip.y=output.psm_cur.y(timeIn);
output.psm_grip.z=output.psm_cur.z(timeIn);
output.psm_grip.t=output.psm_cur.time(timeIn);

if plotoption
    plot(grip_pinch_time,ones(size(grip_pinch_time)),'rx')
end

