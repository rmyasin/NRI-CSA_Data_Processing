function metrics=processArteryExperiment(dataFolder,expIndex,expOrgan,regTimes,regNames,plotOption)
    cpd_dir=getenv('CPDREG');
    featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];
    organFolder=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];

    
    ii=expIndex;
    organLabel=expOrgan;
    
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
    % Process data for when each piece of the experiment is
    % started/finished using artery_status
    firstIndex=find(output.artery_status.data==1,1);
    timeTrim=output.artery_status.time(firstIndex);
    for status=1:3
        lastIndex=find(output.artery_status.data==status,1,'last')+1;
        timeTrim=[timeTrim;output.artery_status.time(lastIndex);output.artery_status.time(lastIndex)];
    end
    timeTrim(end)=[];

    % Transform Micron data from organ frame to robot frame
    % (it's in organ frame for historical reasons, don't worry about why)
    registrationFilePath = [dataFolder filesep regFolder filesep 'Micron2Phantom' num2str(label2num(organLabel)) '.txt'];
    HMicron=readTxtReg(registrationFilePath);
    if isempty(micronTip.pos)
        micronHomog=[];
        warning('No Micron Data')
    else
        micronHomog=HOrgan*(HMicron\[micronTip.pos';ones(1,length(micronTip.pos))]);
        [micronTrim,trimmedTime]=trimBetweenTime(micronHomog(1:3,:)',output.micronTip.time,timeTrim,true);
        
    end
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
    [arteryPlane.n,arteryPlane.p]=fitPlane(arteryInRobot');
    
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
        if ~isempty(micronHomog)
            vplot3(micronHomog(1:3,:)');
        end
        vplot3(organInRobot')
        
        % Plot the force norm data
        figure
        plot(forceNorm)
    end
    
    %% TODO Set up metrics struct
    metrics.coverage=coverage;
    
    
    
    
end