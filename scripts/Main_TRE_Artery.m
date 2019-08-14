organ_reg_pts;
x=organFids0;
[rob,mic]=readPSMRegPts('.','PSMRegPtsVU.txt')

y=[mean(rob.pos{1})', mean(rob.pos{2})', mean(rob.pos{3})' , mean(rob.pos{4})'];

[R,t]=rigidPointRegistration(x,y);
FLE = mean(colNorm(y-(R*x+t))) %in meters


% TRE calculation along artery
[TRE_RMS,F1,F2,F3] = treapprox(X,T,RMS_FLE)

%Get some artery points
[arteryInRobot,HOrgan] = getArteryPoints([dataFolder filesep regFolder],organLabel,featureFolder);


%% getArteryPoints
%% Kidney_A_Artery, Kidney_C_Artery, Kidney_D_Artery (0,2,3)
organLabel='A';
organLabel='C';
organLabel='D';

cpd_dir=getenv('CPDREG');
featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];

fclose('all');

temp=load([featureFolder filesep 'Kidney_' organLabel '_Artery_Pts.mat']);
arteryPointsRaw=temp.ptOutput;
clear('temp');

registrationFilePath = [regFolder filesep 'PSM2Phantom' num2str(label2num(organLabel)) '.txt'];
HOrgan=readTxtReg(registrationFilePath);

arteryHomog=[arteryPointsRaw;ones(1,size(arteryPointsRaw,2))];
arteryReg=HOrgan*arteryHomog;
arteryInRobot=arteryReg(1:3,:)';

