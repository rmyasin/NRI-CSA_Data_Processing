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

function metrics=processArteryIREP(output,arteryInMag,plotOption)

    cur=output.mag_pos;
    forceEst=output.force;
    force_gt=output.force_gt;
    forceTime = force_gt.time;    
    
    
    %% Get position data, find when the robot is in contact
    % Calculate force norm
    forceNorms=sqrt(sum(force_gt.data.^2,2));
    
    % Find positions when force above contact threshold by matching times
    % of when the robot was in contact
    contactIndex=forceNorms>0.1;
    contactTrimTimes=[];
    if contactIndex(1)
        contactTrimTimes=forceTime(1);
    end
    contactTrimTimes=[contactTrimTimes;forceTime(find(diff(contactIndex)~=0))]; %#ok<FNDSB>
    if contactIndex(end)
        contactTrimTimes=[contactTrimTimes;forceTime(end)];
    end
    [curContact,curTimes]=trimBetweenTime(cur.data,cur.time,contactTrimTimes);
    
    %% Find organ data
    timeTrim=[];
    for status=[1:2:9]
        lastIndex=find(output.artery_status.data==status,1,'last');
        timeTrim=[timeTrim;output.artery_status.time(lastIndex);output.artery_status.time(lastIndex+1)];
    end

    curTrim=trimBetweenTime(cur.data,cur.time,timeTrim,true);
    curTrimContact=trimBetweenTime(curContact,curTimes,timeTrim,true);
    
    %% Find distance from the line
    % Metric 1: Lateral error and force tracking while in contact:
    % If the user skips a portion of the curve with no contact, this error metric would not see that.
    
    % 3D errors correlate with force errors, correlates metrics, but
    % we don't have a good way to fit a plane right now, so ignoring
    % projected error
    for jj=1:5
        distance=pdist2(arteryInMag',curTrimContact{jj},'euclidean','Smallest',1);
        meanDistError(jj)=mean(distance);
    end
    
    % Metric 2: how much of the curve is "covered" (closest point) *during* contact.
    % If the user leaves the organ, we will see a lack of coverage (or if
    % they are super far away and miss sections of the artery... will have to look at that if it comes up)
    for jj=1:5
        [~,Index]=pdist2(arteryInMag',curTrimContact{jj},'euclidean','Smallest',1);
        coverage(jj)=length(unique(Index))/length(arteryInMag);
    end
    
    %% Find force folowing errors
    % Calculate y force errors
    forceTrimTrue = trimBetweenTime(force_gt.data,force_gt.time,timeTrim,true);
    fDesired = 0.75; % Desired force is -0.75 N in Y direction
    for jj=1:5 %each individual trial
        forceMeanAppliedNorm(jj)=rms(rowNorm(forceTrimTrue{jj}));
        forceMeanAppliedVert(jj)=mean(abs(forceTrimTrue{jj}(:,2)));
        forceErrorNorm(jj)= rms(rowNorm(forceTrimTrue{jj})-fDesired); 
        forceErrorVert(jj)= rms(forceTrimTrue{jj}(:,2)+fDesired);
    end
    
    %% Set up metrics struct
    forceGTInterp=interp1(output.force_gt.time,output.force_gt.data,forceEst.time);    
    estimationErrorList = (forceEst.data-forceGTInterp);
    forceEstimationError=trimBetweenTime(estimationErrorList,output.force_gt.time,timeTrim,true);
    metrics.forceEstimateVerticalError=[rms(forceEstimationError{1}(:,2));rms(forceEstimationError{2}(:,2));rms(forceEstimationError{3}(:,2))];
    metrics.forceEstimationError = forceEstimationError;
    metrics.forceMeanAppliedNorm=forceMeanAppliedNorm;
    metrics.forceMeanAppliedVert=forceMeanAppliedVert;
    metrics.estimationError = rms(estimationErrorList);
    metrics.coverage=coverage;
    metrics.meanDistance=meanDistError;
    metrics.forceErrorNorm=forceErrorNorm;
    metrics.forceErrorVert=forceErrorVert;
    times=diff(timeTrim)/1E9;
    metrics.completionTime=times(1:2:end)';

    %% Plot results
    if plotOption
        figure
        plot(rowNorm(forceTrimTrue{1}))
        hold on
        plot(rowNorm(forceTrimTrue{2}))
        plot(rowNorm(forceTrimTrue{3}))
        plot(rowNorm(forceTrimTrue{4}))
        plot(rowNorm(forceTrimTrue{5}))
        title('Norm Force Applied')
        legend('Trial 1', 'Trial 2', 'Trial 3','Trial 4','Trial 5')
        prettyFigure
        xlabel('Experiment Time')
        ylabel('Force Applied')
        % Plot the in contact and free space data
%         figure
%         vplot3(curContact)
%         hold on
%         vplot3(arteryInMag')
    end
end