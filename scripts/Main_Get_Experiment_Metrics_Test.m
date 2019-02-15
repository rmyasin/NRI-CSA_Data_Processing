clear
close all
clc

% restoredefaultpath
% addpath(genpath(getenv('ARMA_CL')))

dataFolder='R:\Projects\NRI\User_Study\Data\user1_test_2019-02-13';
% organLetters={'A',10,10}; % THIS NEEDS AN ADJUSTMENT FOR RERUNNING MORE ORGANS
cpd_dir=getenv('CPDREG');
featureFolder= 'R:\Robots\CPD_Reg.git\userstudy_data\PLY';
organFolder=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];

contents=dir(dataFolder);
regTimes=[];
regNames={};
for ii=1:length(contents)
    key = contents(ii).name;
    if startsWith(key,'Registration')
        regNames{end+1}=contents(ii).name;
        regTimes(end+1)=str2num(contents(ii).name(14:end));
    elseif startsWith(key,'Following_Visual') && endsWith(key,'.txt')
        expName{1}=contents(ii).name;
    elseif startsWith(key,'Following_DirectForce') && endsWith(key,'.txt')
        expName{2}=contents(ii).name;
    elseif startsWith(key,'Following_HybridForce') && endsWith(key,'.txt')
        expName{3}=contents(ii).name;
    elseif startsWith(key,'Palpation_DirectForce') && endsWith(key,'.txt')
        expName{4}=contents(ii).name;
    elseif startsWith(key,'Palpation_VisualForce') && endsWith(key,'.txt')
        expName{5}=contents(ii).name;
    end
end

% Read in organ A, get ground truth location of organ/artery
organLabel='A'; %organ A
for ii=1:3
    figure
    [cur,des,force,joint,vProtocol,micronTip]=readRobTxt(datafolder,expName{ii});
    registrationIndex=find((cur.time(1)-regTimes)>0,1,'last'); %find the most recent registration
    regFolder=regNames{registrationIndex};
    arteryInRobot = getArteryPoints([datafolder filesep regFolder],organLabel,featureFolder);
    
    vplot3(cur.pos/1000)
    hold on
    vplot3(arteryInRobot)
    
%     % NEED NEW MICRON TRANSFORM CALCULATION - SOMETHING IS WRONG
%     registrationFilePath = [datafolder filesep regFolder filesep 'Micron2Phantom' num2str(label2num(organLabel)) '.txt'];
%     HMicron=readTxtReg(registrationFilePath);
%     micronHomog=HMicron*[micronTip.pos';ones(1,length(micronTip.pos))];
%     vplot3(micronHomog(1:3,:));
    
    %Add time processing for when each is started/finished
%     USE SIGNALS FROM FOOTPEDAL! MAKE SURE TO RECORD/EXTRACT THOSE!
    
    %QUESTION: when evaluating distance from line, do we project onto the
    %organ/the local plane of the artery? 3D errors would correlate with
    %force errors, which isn't really what we want to do. I think the
    %wisest thing is to project onto the closest surface point during curve
    %following? But then there's also the question of "amount in contact"
%     THIS IS A QUESTION FOR A LATER DATE, WE HAVE ALL THE RELEVANT
%     INFORMATION RIGHT NOW


% HOW DO WE DEAL WITH NO-CONTACT SECTIONS? IF IT'S FOR READJUSTMENT, THAT
% WOULD BE FINE, BUT IF ITS BECAUSE OF COMPLETE LACK OF FOLLOWING, THAT
% WOULD BE BAD. THERE'S A QUESTION OF INTENT WHICH IS DIFFICULT TO PARSE
% Option A: Use all data always. This means that any readjustment would
% be counted as errors in tracking. Also use all force data, so
% readjustment errors would also show up as force errors.
% Option B: Use data only when in contact. This means that if the
% user skips a portion of the curve with no contact, their error metric
% would not see that. Simultaneously, if we only use in-contact forces, the
% force metric would not pick up 'missing' sections of the organ either.
% **Option C: Option B but add a "coverage" metric that looks at how much of
% the curve is "covered" (closest point) during curve-following *during*
% contact. This way if they leave the organ, we will see a lack of coverage
% Users may not leave the surface much, leaving this moot. But it's
% important to think about upfront

    % Add the organ itself
    organInRobot = getOrganPoints([datafolder filesep regFolder],organLabel,organFolder);
    vplot3(organInRobot)

    figure
    plot(force.data)
end

%%
% Read in organ 10, get ground truth location of organ/spheres
% organLabel='10';
organLabel='B';
for ii=4:5
    figure
    [cur,des,force,joint,vProtocol,micronTip]=readRobTxt(datafolder,expName{ii});
    registrationIndex=find((cur.time(1)-regTimes)>0,1,'last'); %find the most recent registration
    regFolder=regNames{registrationIndex};

    spheresInRobot = getSpherePoints([datafolder filesep regFolder],organLabel,featureFolder);
    
    %TODO: get locations saved by user! write that to a topic so that you
    %don't have to post-process anything
    
    organInRobot = getOrganPoints([datafolder filesep regFolder],organLabel,organFolder);
    vplot3(organInRobot)
    hold on
    vplot3(spheresInRobot,'o')
    vplot3(cur.pos/1000)

    
end


%% Trim between time example
% % Find lock orientation topic for turning on/off curve following
% output.lock_time=lock_time(find(lock_time,1):end); % Start with a locking event
% 
% if length(lock_time)
%     % Trim psm data to be only between camera button presses
%     output.psm_locked=trimBetweenTime([output.psm_cur.x',output.psm_cur.y',output.psm_cur.z'],output.psm_cur.time,lock_time);
%     output.ft_locked=trimBetweenTime([output.ft.fx',output.ft.fy',output.ft.fz'],ft.time,lock_time);
%     output.fmtm_vf_curve=trimBetweenTime([fmtm_vf.fx',fmtm_vf.fy',fmtm_vf.fz'],fmtm_vf.time,lock_time);
% end