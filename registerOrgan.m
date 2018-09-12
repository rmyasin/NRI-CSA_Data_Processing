% Inputs
% inPoints: 3x4 matrix of fiducial locations A, B, C, D
% organNum: number between 1 and 6 of the desired organ to register
% mm: if true, inPoints are in mm, otherwise in meters

function [kidneyReg, points] = registerOrgan(inPoints,organNum,mm)
if nargin<3
    mm=true; %
end
kidneyLetter=char(64+organNum); %A, B, C, D, E, F

%% Register kidney to a set of points
fidFolder='R:\Robots\CPD_Reg.git\userstudy_data\FiducialLocations\';
load([fidFolder 'FiducialLocations_' num2str(organNum)],'FidLoc');
if ~mm
    FidLoc=FidLoc/1000; % Convert location to meters
end

[R,t]=rigidPointRegistration(FidLoc,inPoints);
HOrgan=transformation(R,t);

% Load Organ and register to robot frame
cpd_dir=getenv('CPDREG');
organDir=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];
plyDir = [cpd_dir filesep 'userstudy_data' filesep 'PLY' filesep];
temp=load([organDir filesep 'Kidney_' kidneyLetter '_iter_100_NoOpt.mat']);
if ~mm
    kidneyPointsRaw=temp.T.Y/1000';
else
    kidneyPointsRaw=temp.T.Y';
end
clear('temp');
kidneyHomog=[kidneyPointsRaw;ones(1,size(kidneyPointsRaw,2))];
kidneyReg=HOrgan*kidneyHomog;

% return Artery Points
if organNum==1 || organNum==3 || organNum ==4
    load([plyDir 'Kidney_' kidneyLetter '_Artery_Pts'],'ptOutput');
    if mm
        points=ptOutput*1000;
    else
        points=ptOutput;
    end
else
    load([plyDir 'Kidney_' kidneyLetter '_Sphere_Pts'],'ptOutput');
    if mm
        points=ptOutput*1000;
    else
        points=ptOutput;
    end
end
points=R*points+t;

end