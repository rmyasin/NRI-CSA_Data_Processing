% Takes saved data from SaveExperimentData() and calculates metrics for NRI
% user study of "ablation" along a path
% % Inputs:
% dataFolder - 
% expIndex - 
% expOrgan - 
% regTimes - 
% regNames - 
% plotOption -
% % Outputs:
% metrics - 

function metrics=processArteryExperiment(dataFolder,expIndex,expOrgan,regTimes,regNames,plotOption,useMicron)
if nargin<7
    useMicron=false;
end
    %% Pick out the right experiment number and organ number
    ii=expIndex;
    organLabel=expOrgan;
        
    %% Read the robot data from mat file
    load([dataFolder filesep 'matlab' filesep 'Output' num2str(ii)],'output')
    cur=output.psm_cur;
    force=output.force;
    forceTime = force.time;
    micronTip=output.micronTip;
    
    %% Get position data, find when the robot is in contact
    % Calculate force norm
    forceNorms=sqrt(sum(output.force.data.^2,2));
    
    % Find positions when force above contact threshold by matching times
    % of when the robot was in contact
    contactIndex=forceNorms>0.15;
    contactTrimTimes=[];
    if contactIndex(1)
        contactTrimTimes=forceTime(1);
    end
    contactTrimTimes=[contactTrimTimes;forceTime(find(diff(contactIndex)~=0))]; %#ok<FNDSB>
    if contactIndex(end)
        contactTrimTimes=[contactTrimTimes;forceTime(end)];
    end
    [curContact,curTimes]=trimBetweenTime(cur.pos/1000,cur.time,contactTrimTimes);
    
    %% Find the most recent organ registration
    registrationIndex=find((cur.time(1)-regTimes)>0,1,'last');
    regFolder=regNames{registrationIndex};
    
    %% Find organ data
    cpd_dir=getenv('CPDREG');
    featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];
    organFolder=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];
    % Get ground truth organ/points
    organInRobot = getOrganPoints([dataFolder filesep regFolder],organLabel,organFolder);
    [arteryInRobot,HOrgan] = getArteryPoints([dataFolder filesep regFolder],organLabel,featureFolder);

    %% Get micron data
    % Process data for when each piece of the experiment is
    % started/finished using artery_status (corresponds to pedal presses)
%     firstIndex=find(output.artery_status.data==1,1);
%     timeTrim=output.artery_status.time(firstIndex);
    timeTrim=[];
    for status=[1:6]
        lastIndex=find(output.artery_status.data==status,1,'last');
        timeTrim=[timeTrim;output.artery_status.time(lastIndex)];
    end
    
    if size(unique(output.artery_status.data))~=size(output.artery_status.data)
        pause;
    end

    % Transform Micron data from organ frame to robot frame
    % (it's in organ frame for historical reasons, don't worry about why)
    registrationFilePath = [dataFolder filesep regFolder filesep 'Micron2Phantom' num2str(label2num(organLabel)) '.txt'];
    HMicron=readTxtReg(registrationFilePath);
    if isempty(micronTip.pos)
        micronHomog=[];
        warning('No Micron Data')
    else
        micronHomog=HOrgan*(HMicron\[micronTip.pos';ones(1,length(micronTip.pos))]);
        micronTrim=trimBetweenTime(micronHomog(1:3,:)',output.micronTip.time,timeTrim,true);
        [micronContact,micronContactTimes]=trimBetweenTime(micronHomog(1:3,:)',output.micronTip.time,contactTrimTimes);
        micronTrimContact=trimBetweenTime(micronContact,micronContactTimes,timeTrim,true);
    end
    curTrim=trimBetweenTime(cur.pos/1000,cur.time,timeTrim,true);
    curTrimContact=trimBetweenTime(curContact,curTimes,timeTrim,true);

    if useMicron
        curTrim=micronTrim;
        curTrimContact=micronTrimContact;
    end
    
    %% Find distance from the line
    % Metric 1: Lateral error and force tracking while in contact:
    % If the user skips a portion of the curve with no contact, this error metric would not see that.

    % Do we want project errors or 3D Errors?
    % 3D errors would correlate with force errors, correlates metrics
    [arteryPlane.n,arteryPlane.p]=fitPlane(arteryInRobot');
    
%     if plotOption
%         vplot3(arteryInRobot)
%         hold on
%         plotPlane(arteryPlane.n,arteryPlane.p,0.04)
%     end
    
    for jj=1:3
        curProj=proj_onto_a_plane(arteryPlane,curTrim{jj});
        distance=pdist2(arteryInRobot,curTrim{jj},'euclidean','Smallest',1);
        dProj=pdist2(arteryInRobot,curProj,'euclidean','Smallest',1);
        
        meanDistError(jj)=mean(distance);
        meanProjDist(jj)=mean(dProj);

%         if plotOption
%             vplot3(curProj,'.')
%             hold on
%         end
    end

    
    % Metric 2: how much of the curve is "covered" (closest point) *during* contact.
    % If the user leaves the organ, we will see a lack of coverage (or if
    % they are super far away and miss sections of the artery... will have to look at that if it comes up)
    for jj=1:3
        [~,Index]=pdist2(arteryInRobot,curTrimContact{jj},'euclidean','Smallest',1);
        coverage(jj)=length(unique(Index))/length(arteryInRobot);
    end
    
    %% Find force folowing errors
    % Don't include when not in contact, don't need to follow forces then
    forceNorm=rowNorm(force.data);
    forceNormTrim=trimBetweenTime(forceNorm,force.time,timeTrim,true);
    for jj=1:3
        forceNormInContact=forceNormTrim{jj}(forceNormTrim{jj}>0.15);
        forceError(jj)=rms(forceNormInContact-2);
    end
    
    %% Set up metrics struct
    metrics.coverage=coverage;
    metrics.meanDistance=meanDistError;
    metrics.meanProjDistance=meanProjDist;
    metrics.forceError=forceError;
    times=diff(timeTrim)/1E9;
    metrics.completionTime=times(1:2:end)';

    %% Plot results
    if plotOption
        % Plot the in contact and free space data
        figure
        vplot3(curContact)
        hold on
        vplot3(arteryInRobot)
        if ~isempty(micronHomog)
            vplot3(micronHomog(1:3,:)');
        end
        vplot3(organInRobot')
    end
end