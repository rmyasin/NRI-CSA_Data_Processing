clear
close all
% clc
addpath(genpath(getenv('ECLDIR'))) % get quatlib

addpath(genpath('Utilities'))
fidFolder='R:\Robots\CPD_Reg.git\userstudy_data\FiducialLocations';
addpath(fidFolder)
for ii=1:6
    load(['FiducialLocations_' num2str(ii)]);
    fiducials{ii}=FidLoc/1000;
end

filenames={'R:\Projects\NRI\User_Study\Data\data\JHU_Registration\PSMRegPts.txt'
           'R:\Projects\NRI\User_Study\Data\data\JHU_Registration\PSMRegPtsJHU.txt';};

p_VU_python = [-0.10604732 -0.18797096 -0.10305663]';
q_VU_python = [-0.39879553163917775 0.002071089312541772 0.9169612234797171 0.011830011338348219];
% q_VU_python = [q_VU_python(end) q_VU_python(1:3)];
R_VU_python = quat2rot(q_VU_python);
H_VU_python = transformation(R_VU_python,p_VU_python);

p_JHU_python=[-0.0187626 -0.21715984 -0.02998706]';
q_JHU_python=[-0.394798918529 0.121035768 0.83727644 -0.358402456];
R_JHU_python = quat2rot(q_JHU_python);
H_JHU_python = transformation(R_JHU_python,p_JHU_python);

for ii=1:length(filenames)
    file=fopen(filenames{ii});
    
    line=fgetl(file);
    mode=-1;
    %%
    % THIS DOESN'T AVERAGE THE QUATERNIONS, BUT WE DON'T USE THEM NOW SO OK
    robPoints=zeros(3,4);
    robQuat{4}=[];
    micronPoints=zeros(3,4);
    micronQuat{4}=[];
    count=zeros(4,1);
    while line ~=-1
        if startsWith(line,'Rob Pts at ')
            mode =1;
            letter = char(upper(line(end)))-64;
        elseif startsWith(line,'Micron Pts at ')
            mode = 2;
            letter = char(upper(line(end)))-64;
        elseif mode == 1
            mode=-1;
            robPoints(:,letter)=robPoints(:,letter)+str2double(split(line));
            robQuat{letter}=[robQuat{letter}, str2double(split(fgetl(file)))];
            count(letter)=count(letter)+1;
        elseif mode == 2
            mode=-1;
            micronPoints(:,letter)=micronPoints(:,letter)+str2double(split(line));
            micronQuat{letter}={micronQuat(letter), str2double(split(fgetl(file)))};
        end
        line=fgetl(file);
    end
    robPoints=robPoints./count';
    micronPoints=robPoints./count';
    
    [R,t]=rigidPointRegistration(robPoints,fiducials{1});
    
    errorMat{ii}=R*robPoints+t-fiducials{1};
    
    if ii==1
        H_VU=transformation(R,t);
        p_VU=t;
        q_wxyz_VU=rot2quat(R);
        errorMatPy{ii}=R_VU_python*robPoints+p_VU_python-fiducials{1};
    elseif ii==2
        p_JHU=t;
        H_JHU=transformation(R,t);
        q_wxyz_JHU=rot2quat(R);
        errorMatPy{ii}=R_JHU_python*robPoints+p_JHU_python-fiducials{1};
    end
end



