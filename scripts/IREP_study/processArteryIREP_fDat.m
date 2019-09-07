% TODO - explain function

function metrics=processArteryIREP_fDat(fDat,arteryInMag,plotOption)

    % Pull data from experiment struct
    cur=fDat.M4(:,1:3);
    forceEst=fDat.FsenseOnline;
    force_gt=fDat.WRENCH_measured(:,1:3);
    
    %% Find organ data
    timeTrim=find(diff(fDat.FCMD(:,end)));
    curTrim=trimBetweenTime(cur,(1:length(cur))',timeTrim',true);
    
    %% Find distance from the line
    % Metric 1: Lateral error
    for jj=1:length(curTrim)
        distance=pdist2(arteryInMag',curTrim{jj},'euclidean','Smallest',1);
        meanDistError(jj)=mean(distance);
    end
    
    %% Find force folowing errors
    % Don't include when not in contact, don't need to follow forces then
    % Calculate y force errors
    forceTrimTrue = trimBetweenTime(force_gt,(1:length(force_gt))',timeTrim',true);
    fDesired = 0.75; % Desired force is -0.75 N in Y direction
    for jj=1:length(forceTrimTrue) %each individual trial
        forceMeanAppliedNorm(jj)=rms(rowNorm(forceTrimTrue{jj}));
        forceMeanAppliedVert(jj)=mean(abs(forceTrimTrue{jj}(:,2)));
        forceErrorNorm(jj)= rms(rowNorm(forceTrimTrue{jj})-fDesired); 
        forceErrorVert(jj)= rms(forceTrimTrue{jj}(:,2)+fDesired);
    end
    
    %% Set up metrics struct
    for ii=1:length(forceTrimTrue)
        meanAppliedVerticalForce(ii) = mean(abs(forceTrimTrue{ii}(1:end,2)));
    end
    
    estimationErrorList = (forceEst-force_gt);
    forceEstimationError=trimBetweenTime(estimationErrorList,(1:length(force_gt))',timeTrim,true);
    for ii=1:length(forceEstimationError)
        estimationError.Norm(ii)=mean(rowNorm(forceEstimationError{ii}));
        estimationError.Y(ii)=mean(rowNorm(forceEstimationError{ii}(:,1)));
        estimationError.YZ(ii)=mean(rowNorm(forceEstimationError{ii}(:,1:2)));
    end
    
    metrics.meanAppliedVerticalForce=meanAppliedVerticalForce;
    metrics.forceAppliedCell = forceTrimTrue;
    metrics.estimationError = estimationError;
%     metrics.coverage=coverage;
    metrics.meanDistance=meanDistError;
    times=diff(timeTrim)/1E9;
    metrics.completionTime=times(1:2:end)';

    %% Plot results
    if plotOption
        figure
        plot(rowNorm(forceTrimTrue{1}))
        legendText={'Trial 1'};
        hold on
        for ii=2:length(forceTrimTrue)
            plot(abs(forceTrimTrue{ii}(:,2)))
            legendText{end+1}=['Trial ' num2str(ii)];
        end
        title('Vertical Force Applied')
        legend(legendText);
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