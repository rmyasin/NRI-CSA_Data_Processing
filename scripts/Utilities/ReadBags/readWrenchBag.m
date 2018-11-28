function structOut=readWrenchBag(rawWrench)
if iscell(rawWrench)
    structOut.time=[];
    rawWrenchMsg=[];
    for ii=1:length(rawWrench)
        structOut.time=[structOut.time;rawWrench{ii}.MessageList.Time];
        rawWrenchMsg=[rawWrenchMsg;rawWrench{ii}.readMessages];
    end
else    
    structOut.time=rawWrench.MessageList.Time;
    rawWrenchMsg=rawWrench.readMessages;
end

rawWrenchList=[rawWrenchMsg{:}];
rawWrenchListB=[rawWrenchList.Wrench];
rawForceList=[rawWrenchListB.Force];
structOut.fx=[rawForceList.X];
structOut.fy=[rawForceList.Y];
structOut.fz=[rawForceList.Z];

rawTorqueList=[rawWrenchListB.Torque];
structOut.tx=[rawTorqueList.X];
structOut.ty=[rawTorqueList.Y];
structOut.tz=[rawTorqueList.Z];

end