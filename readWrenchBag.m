function structOut=readWrenchBag(rawWrench)
structOut.time=rawWrench.MessageList.Time;

rawWrenchMsg=rawWrench.readMessages;
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