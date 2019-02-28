function [organInRobot,HOrgan,organPointsRaw ]= getOrganPoints(regFolder,organLabel,organFolder)
temp=load([organFolder filesep 'Kidney_' organLabel '_iter_100_NoOpt.mat']);
organPointsRaw=temp.T.Y'/1000;
clear('temp');

registrationFilePath = [regFolder filesep 'PSM2Phantom' num2str(label2num(organLabel)) '.txt'];
HOrgan=readTxtReg(registrationFilePath);

organHomog=[organPointsRaw;ones(1,size(organPointsRaw,2))];
organReg=HOrgan*organHomog;
organInRobot=organReg(1:3,:);

end