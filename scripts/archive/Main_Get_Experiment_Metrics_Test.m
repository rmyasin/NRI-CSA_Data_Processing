clear
close all
clc

restoredefaultpath
addpath(genpath(getenv('ARMA_CL')))
addpath(genpath('Utilities'))

dataFolder='R:\Projects\NRI\User_Study\Data\user22';
% dataFolder='R:\Projects\NRI\User_Study\Data\user12';
plotOption=true;
% cpd_dir ='/home/arma/catkin_ws/src/cpd-registration';

cpd_dir=getenv('CPDREG');
featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];
organFolder=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];

[~,dataFolderName]=fileparts(dataFolder);
resultsStruct.userNumber=str2double(dataFolderName(5:end));
contents=dir(dataFolder);
regTimes=[];
regNames={};
expOrgan{5}={};
expName{5}={};
expOrgan{6}={};
expName{6}={};

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
    elseif startsWith(key,'Following_BarVision') && endsWith(key,'.txt')
        start = length('Following_BarVision')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{2}= key(start:finish);
        expName{2}=contents(ii).name;
    elseif startsWith(key,'Following_DirectForce') && endsWith(key,'.txt')
        start = length('Following_DirectForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{3}= key(start:finish);
        expName{3}=contents(ii).name;
    elseif startsWith(key,'Following_HybridForce') && endsWith(key,'.txt')
        start = length('Following_HybridForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{4}= key(start:finish);
        expName{4}=contents(ii).name;
    elseif startsWith(key,'Palpation_DirectForce') && endsWith(key,'.txt')
        start = length('Palpation_DirectForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{5}= {expOrgan{5}{:},key(start:finish)};
        expName{5}={expName{5}{:},contents(ii).name};
    elseif startsWith(key,'Palpation_VisualForce') && endsWith(key,'.txt')
        start = length('Palpation_VisualForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{6}= {expOrgan{6}{:},key(start:finish)};
        expName{6}={expName{6}{:},contents(ii).name};
    end
end

for ii=1:4
    [output]=readRobTxt(dataFolder,expName{ii});
    save([dataFolder filesep 'Output' num2str(ii)],'output')
end
for ii=5:6
    for jj=1:length(expOrgan{ii})
        output=readRobTxt(dataFolder,expName{ii}{jj});
        save([dataFolder filesep 'Output' num2str(ii) '_' num2str(jj)],'output')
    end
end

%% Process artery-following experiment
for ii=1:4
    organLabel=expOrgan{ii};
    
    %% Read the robot data from mat file
    load([dataFolder filesep 'Output' num2str(ii)],'output')
    cur=output.psm_cur;
    des=output.psm_des;
    force=output.force;
    forceTime = force.time;
    micronTip=output.micronTip;
    %% Get position data, find when the robot is in contact
    
    % Calculate force norm
    forceNorms=sqrt(sum(output.force.data.^2,2));
    
    % Find positions when force above contact threshold by matching times
    contactIndex=forceNorms>0.1;
    contactTrimTimes=[];
    if contactIndex(1)
        contactTrimTimes=forceTime(1);
    end
    contactTrimTimes=[contactTrimTimes;forceTime(find(diff(contactIndex)~=0))];
    if contactIndex(end)
        contactTrimTimes=[contactTrimTimes;forceTime(end)];
    end
    
    [curContact,curTimes]=trimBetweenTime(cur.pos/1000,cur.time,contactTrimTimes);
    
    %% Find the organ registration and the artery/organ points
    % find the most recent registration
    registrationIndex=find((cur.time(1)-regTimes)>0,1,'last');
    regFolder=regNames{registrationIndex};
    
    % Get ground truth points
    [arteryInRobot,HOrgan] = getArteryPoints([dataFolder filesep regFolder],organLabel,featureFolder);
    organInRobot = getOrganPoints([dataFolder filesep regFolder],organLabel,organFolder);

    %% Get micron data
    % Transform Micron data from organ frame to robot frame
    % (it's in organ frame for historical reasons, don't worry about why)
    registrationFilePath = [dataFolder filesep regFolder filesep 'Micron2Phantom' num2str(label2num(organLabel)) '.txt'];
    HMicron=readTxtReg(registrationFilePath);
    micronHomog=HOrgan*(HMicron\[micronTip.pos';ones(1,length(micronTip.pos))]);
    
    % Process data for when each piece of the experiment is
    % started/finished using artery_status
    firstIndex=find(output.artery_status.data==1,1);
    timeTrim=output.artery_status.time(firstIndex);
    for status=1:3
        lastIndex=find(output.artery_status.data==status,1,'last')+1;
        timeTrim=[timeTrim;output.artery_status.time(lastIndex);output.artery_status.time(lastIndex)];
    end
    timeTrim(end)=[];
    
    [micronTrim,trimmedTime]=trimBetweenTime(micronHomog(1:3,:)',output.micronTip.time,timeTrim,true);
    curTrim=trimBetweenTime(cur.pos/1000,cur.time,timeTrim,true);
    curTrimContact=trimBetweenTime(curContact,curTimes,timeTrim,true);
    
    %% TEMP PLOTTING, REMOVE AFTER TESTING
%     TODO do an experiment with intentional liftoff during following to
%     see the result and make sure this is captured
%     for jj=1:3
%         figure
%         vplot3(curTrim{jj});
%         hold on
%         vplot3(curTrimContact{jj});
%     end

    %% Find distance from the line
    % Metric 1: Lateral error and force tracking while in contact:
    % If the user skips a portion of the curve with no contact, this error metric would not see that.

    % Do we want project errors or 3D Errors?
    % 3D errors would correlate with force errors, correlates metrics
    [arteryPlane.n,arteryPlane.p]=fitPlane(arteryInRobot);
    
    for jj=1:3
        curProj{jj}=proj_onto_a_plane(arteryPlane,curTrim{jj});
        [D{jj},I{jj}]=pdist2(arteryInRobot,curTrim{jj},'euclidean','Smallest',1);
        dProj{jj}=pdist2(arteryInRobot,curProj{jj},'euclidean','Smallest',1);
        vplot3(curTrim{jj},'.')
        
        hold on
        move=arteryInRobot(I{jj},:)-curTrim{jj};
        plotVec(move',curTrim{jj}','k--')
        meanDistError(jj)=mean(D{jj});
        meanProjDist(jj)=mean(dProj{jj});
    end
    vplot3(arteryInRobot)
    plotPlane(arteryPlane.n,arteryPlane.p,0.04)
    
    % Metric 2: how much of the curve is "covered" (closest point) *during* contact.
    % If the user leaves the organ, we will see a lack of coverage (or if
    % they are super far away and miss sections of the artery... will have to look at that if it comes up)
    for jj=1:3
%         plot(unique(sort(I{jj})))
        coverage(jj)=length(unique(I{jj}))/length(arteryInRobot);
    end
    
    %% Find force folowing errors
    forceNorm=sqrt(sum(force.data.^2,2));
    %Don't include when not in contact, don't need to follow forces then
    contactforceNorm=trimBetweenTime(forceNorm,force.time,contactTrimTimes); 
    
    %% Plot results
    if plotOption
        % Plot the in contact and free space data
        figure
        vplot3(curContact)
        hold on
        vplot3(arteryInRobot)
        vplot3(micronHomog(1:3,:)');
        vplot3(organInRobot')
        
        % Plot the force norm data
        figure
        plot(forceNorm)
    end
end


%%
% Read in organ, get ground truth location of organ/spheres
for ii=5:6
    for jj=1:length(expOrgan{ii})
        organLabel=expOrgan{ii}{jj};
        figure
        % Read data file
%         output=readRobTxt(dataFolder,expName{ii}{jj});
        load([dataFolder filesep 'Output' num2str(ii) '_' num2str(jj)],'output')

        cur=output.psm_cur;
        micronTip=output.micronTip;

        % Find the most recent registration
        registrationIndex=find((cur.time(1)-regTimes)>0,1,'last');
        regFolder=regNames{registrationIndex};

        % Get Sphere Points
        [spheresInRobot,~,H1,sphereRaw] = getSpherePoints([dataFolder filesep regFolder],organLabel,featureFolder);

        % Get selected POI times
        savedPoints=output.display_points.data{end}';

        % Get Organ Points
        [organInRobot,H2,organRaw] = getOrganPoints([dataFolder filesep regFolder],organLabel,organFolder);

        % Plot results
        vplot3(organInRobot')
        hold on
        vplot3(spheresInRobot','o')
        vplot3(savedPoints,'x')

        registrationFilePath = [dataFolder filesep regFolder filesep 'Micron2Phantom' num2str(label2num(organLabel)) '.txt'];
        HMicron=readTxtReg(registrationFilePath);
        micronHomog=H2*(HMicron\[micronTip.pos';ones(1,length(micronTip.pos))]);
        vplot3(micronHomog(1:3,:)');

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
%         TODO: USE A 'PALPATION ON' VARIABLE TO CALCULATE TIME
        experimentLengthInS = (output.psm_cur.time(end)-output.psm_cur.time(1))/1E9;
    end
end
