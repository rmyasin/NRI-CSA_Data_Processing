function output=readVisualArteryBag(BagName)
tic
time_topic = select(BagName, 'Time', [BagName.StartTime BagName.EndTime], 'Topic', '/tf');
output.rawTime=time_topic.MessageList.Time;
output.time=time_topic.MessageList.Time-BagName.StartTime;
tic
psm_cur_topic=select(BagName,'Topic','/dvrk/PSM2/position_cartesian_current','Time', [BagName.StartTime BagName.EndTime]);
toc
psm_des_topic=select(BagName,'Topic','/dvrk/PSM2/position_cartesian_desired','Time', [BagName.StartTime BagName.EndTime]);
mtm_des_topic=select(BagName,'Topic','/dvrk/MTMR/position_cartesian_current','Time', [BagName.StartTime BagName.EndTime]);

ft_topic=select(BagName,'Topic','/dvrk/PSM2_FT/raw_wrench','Time', [BagName.StartTime BagName.EndTime]);
% ftpsm_topic=select(BagName,'Topic','/dvrk/PSM2/wrench','Time', [BagName.StartTime BagName.EndTime]);

% mtm_wrench_topic=select(BagName,'Topic','/dvrk/MTMR/wrench_body_current','Time', [BagName.StartTime BagName.EndTime]);
% mtm_vfwrench_topic=select(BagName,'Topic','/dvrk/MTMR/vf_wrench','Time', [BagName.StartTime BagName.EndTime]);

% Plot robot motion
output.psm_cur=readPoseStampedBag(psm_cur_topic);
output.psm_des=readPoseStampedBag(psm_des_topic);
output.mtm_des=readPoseStampedBag(mtm_des_topic);

% Read wrench bags
output.ft=readWrenchBag(ft_topic);
% ftpsm=readWrenchBag(ftpsm_topic);
% fMT=readWrenchBag(mtm_wrench_topic);
% fmtm_vf=readWrenchBag(mtm_vfwrench_topic);

% Find lock orientation topic for turning on/off curve following
lock_orientation_topic=select(BagName,'Topic','/dvrk/MTMR_PSM2/lock_rotation','Time', [BagName.StartTime BagName.EndTime]);
lock_time=lock_orientation_topic.MessageList.Time;
output.lock_time=lock_time(find(lock_time,1):end); % Start with a locking event

% Trim psm data to be only between camera button presses
output.psm_locked=trimBetweenTime([output.psm_cur.x',output.psm_cur.y',output.psm_cur.z'],output.psm_cur.time,lock_time);
output.ft_locked=trimBetweenTime([output.ft.fx',output.ft.fy',output.ft.fz'],ft.time,lock_time);
output.fmtm_vf_curve=trimBetweenTime([fmtm_vf.fx',fmtm_vf.fy',fmtm_vf.fz'],fmtm_vf.time,lock_time);

end
