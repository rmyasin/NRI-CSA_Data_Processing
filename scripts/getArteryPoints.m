function [arteryInRobot,HOrgan] = getArteryPoints(regFolder,organLabel,organFolder)
temp=load([organFolder filesep 'Kidney_' organLabel '_Artery_Pts.mat']);
arteryPointsRaw=temp.ptOutput;
clear('temp');

registrationFilePath = [regFolder filesep 'PSM2Phantom' num2str(label2num(organLabel)) '.txt'];
HOrgan=readTxtReg(registrationFilePath);

arteryHomog=[arteryPointsRaw;ones(1,size(arteryPointsRaw,2))];
arteryReg=HOrgan*arteryHomog;
arteryInRobot=arteryReg(1:3,:)';

end