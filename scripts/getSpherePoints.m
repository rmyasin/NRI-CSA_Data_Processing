function sphereInRobot = getSpherePoints(regFolder,organLabel,organFolder)
temp=load([organFolder filesep 'Kidney_' organLabel '_Sphere_Pts.mat']);
spherePointsRaw=temp.ptOutput;
clear('temp');





registrationFilePath = [regFolder filesep 'PSM2Phantom' num2str(label2num(organLabel)) '.txt'];
HOrgan=readTxtReg(registrationFilePath);

sphereHomog=[spherePointsRaw;ones(1,size(spherePointsRaw,2))];
sphereReg=HOrgan*sphereHomog;
sphereInRobot=sphereReg(1:3,:)';

end