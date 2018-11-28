function output=readContinuousBag(PalpBag)
psm_cur_topic =     select(PalpBag,'Topic','/dvrk/PSM2/position_cartesian_current','Time', [PalpBag.StartTime PalpBag.EndTime]);
psm_des_topic =     select(PalpBag,'Topic','/dvrk/PSM2/position_cartesian_desired','Time', [PalpBag.StartTime PalpBag.EndTime]);
ft_topic =          select(PalpBag,'Topic','/atinetft/wrench','Time', [PalpBag.StartTime PalpBag.EndTime]);

output.psm_cur=readPoseStampedBag(psm_cur_topic);
output.psm_des=readPoseStampedBag(psm_des_topic);
output.ft=readWrenchBag(ft_topic);

end

