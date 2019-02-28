clear
close all
% clc

% restoredefaultpath
% addpath(genpath(getenv('ARMA_CL')))

% dataFolder='R:\Projects\NRI\User_Study\Data\user1_test_2019-02-13';
% dataFolder='R:\Projects\NRI\User_Study\Data\user3_20190220_test';
% dataFolder='R:\Projects\NRI\User_Study\Data\user3_20190220_test';
% dataFolder='R:\Projects\NRI\User_Study\Data\user3_20190220_test';


cpd_dir=getenv('CPDREG');
% cpd_dir ='/home/arma/catkin_ws/src/cpd-registration';
dataFolder='R:\Projects\NRI\User_Study\Data\user4';
% dataFolder='/home/arma/catkin_ws/data/user5';

featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];
organFolder=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];

[~,dataFolderName]=fileparts(dataFolder);
resultsStruct.userNumber=str2double(dataFolderName(5));
contents=dir(dataFolder);
regTimes=[];
regNames={};
for ii=1:length(contents)
    key = contents(ii).name;
    if startsWith(key,'Registration')
        regNames{end+1}=contents(ii).name;
        regTimes(end+1)=str2num(contents(ii).name(14:end));
    elseif startsWith(key,'Following_Visual') && endsWith(key,'.txt')
        start = length('Following_Visual')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{1}= key(start:finish);
        expName{1}=contents(ii).name;
    elseif startsWith(key,'Following_DirectForce') && endsWith(key,'.txt')
        start = length('Following_DirectForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{2}= key(start:finish);
        
        expName{2}=contents(ii).name;
    elseif startsWith(key,'Following_HybridForce') && endsWith(key,'.txt')
        start = length('Following_HybridForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{3}= key(start:finish);
        
        expName{3}=contents(ii).name;
    elseif startsWith(key,'Palpation_DirectForce') && endsWith(key,'.txt')
        start = length('Palpation_DirectForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{4}= key(start:finish);
        
        expName{4}=contents(ii).name;
    elseif startsWith(key,'Palpation_VisualForce') && endsWith(key,'.txt')
        start = length('Palpation_VisualForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{5}= key(start:finish);
        
        expName{5}=contents(ii).name;
    end
end

%%
% Read in organ A, get ground truth location of organ/artery
for ii=2:3
    organLabel=expOrgan{ii};
    
    [output,vProtocol]=readRobTxt(dataFolder,expName{ii});
    cur=output.psm_cur;
    des=output.psm_des;
    force=output.force;
    forceTime = force.time;
    
%     Find when the robot is in contact
    forceNorms=sqrt(sum(output.force.data.^2,2));
    contactIndex=forceNorms>0.1;
    contactChangeTimes=[];
    if contactIndex(1)
        contactChangeTimes=[contactChangeTimes;forceTime(1)];
    end
    contactChangeTimes=[contactChangeTimes;forceTime(find(diff(contactIndex)~=0))];
    if contactIndex(end)
        contactChangeTimes=[contactChangeTimes;forceTime(end)];
    end
    
    curLeaveIndex=zeros(size(cur.time));
    for jj=2:2:(length(contactChangeTimes)-1)
        curLeaveIndex=curLeaveIndex | (cur.time>contactChangeTimes(jj) & cur.time<contactChangeTimes(jj+1));
    end
    if ~contactChangeTimes(end)
        curLeaveIndex(end)=1;
    end
    vplot3(cur.pos(curLeaveIndex,:))
    hold on
    vplot3(cur.pos(~curLeaveIndex,:))
    
%     diff(contactTimes)
%     find((diff(contactIndex)~=0))
%     contactTimes=output.force.time(contactIndex);
% 
% %     DONT CHECK DISCRETE POINTS, GET RANGES OF TIMES WHEN IN/OUT OF
% %     CONTACT
% contactThresh=0.1;
% startContact=forceNorms(1)>contactThresh;
% changedTimes = contactTimes(diff(contactTimes/1E9)>0.05);
% 
%     t1 = contactTimes;
%     t2 = output.psm_cur.time;
%     [val, idxB] = min( abs(t1(:)-t2(:)') ,[],2);
%     val/1E9<0.01
%     closeTimes=t2(idxB);
%     savedPoints=output.psm_cur.pos(idxB,:)/1000;

%     contactPositions = 

    micronTip=output.micronTip;
    registrationIndex=find((cur.time(1)-regTimes)>0,1,'last'); %find the most recent registration
    regFolder=regNames{registrationIndex};
    [arteryInRobot,HOrgan] = getArteryPoints([dataFolder filesep regFolder],organLabel,featureFolder);
    
    figure
    vplot3(cur.pos/1000)
    hold on
    vplot3(arteryInRobot)
    
    % Micron data is reported in organ frame, which is weird, but ok
    registrationFilePath = [dataFolder filesep regFolder filesep 'Micron2Phantom' num2str(label2num(organLabel)) '.txt'];
    HMicron=readTxtReg(registrationFilePath);
    micronHomog=HOrgan*(HMicron\[micronTip.pos';ones(1,length(micronTip.pos))]);
    vplot3(micronHomog(1:3,:)');
    
    % Add time processing for when each is started/finished
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
    organInRobot = getOrganPoints([dataFolder filesep regFolder],organLabel,organFolder);
    vplot3(organInRobot)

    figure
    forceNorm=sqrt(sum(force.data.^2,2));
    plot(forceNorm)
end

%%
% Read in organ, get ground truth location of organ/spheres
for ii=4:5
    organLabel=expOrgan{ii};
    figure
    % Read data file
    output=readRobTxt(dataFolder,expName{ii});
    cur=output.psm_cur;
    micronTip=output.micronTip;
    
    % Find the most recent registration
    registrationIndex=find((cur.time(1)-regTimes)>0,1,'last'); 
    regFolder=regNames{registrationIndex};

	% Get Sphere Points
    [spheresInRobot,H1,sphereRaw] = getSpherePoints([dataFolder filesep regFolder],organLabel,featureFolder);
    
    % Get times closest to selected POI times
    t1 = output.poi_points.time;
    t2 = output.psm_cur.time;
    [~, idxB] = min( abs(t1(:)-t2(:)') ,[],2);
    savedPoints=output.psm_cur.pos(idxB,:)/1000;
    
    % Get Organ Points
    [organInRobot,H2,organRaw] = getOrganPoints([dataFolder filesep regFolder],organLabel,organFolder);
    
    % Plot results
    vplot3(organInRobot)
    hold on
    vplot3(spheresInRobot,'o')
    vplot3(savedPoints,'x')
    vplot3(output.micronTip.pos);
    
    
%     TODO: need to convert robot selected points to closest on
%     organ and then distance to the sphere center (which I think we've
%     maybe already converted to closest mesh points)
    
% Metric question: How to represent error in selection?
%     average distace from selected spot to hard nodule?
%     average distance from hard nodule to closest selection?

% Metric question: how do we count that a nodule has been found?
%     Define some arbitrary epsilon that indicates a nodule has been
%     "located"
    
    % Total Experiment time in seconds (convert from nanoseconds)
    experimentLengthInS = (output.psm_cur.time(end)-output.psm_cur.time(1))/1E9;
end
