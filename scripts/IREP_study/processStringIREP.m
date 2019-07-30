function metrics = processStringIREP(dataStruct,desiredForce,plotOption)

numExperiments=max(dataStruct.string_status.data);
if numExperiments~=10
    warning('Experiment Does not have 8 string experiments!')
end

pullIndex=0;
for ii=2:length(dataStruct.string_status.data)
    if dataStruct.string_status.data(ii)>dataStruct.string_status.data(ii-1)
        pullIndex=pullIndex+1;
        pullTimes(pullIndex)=dataStruct.string_status.time(ii);
    else
        pullIndex=pullIndex-1;
    end
end

pullForces=interp1(dataStruct.force_gt.time,dataStruct.force_gt.data,pullTimes(1:end));
pullForcesEst=interp1(dataStruct.force.time,dataStruct.force.data,pullTimes(1:end));


forceGTInterp=interp1(dataStruct.force_gt.time,dataStruct.force_gt.data,dataStruct.force.time);    
estimationErrorList = (dataStruct.force.data-forceGTInterp);
metrics.stringPullForce = pullForces;
metrics.estimationError = rms(rowNorm(estimationErrorList));
metrics.pullErrors=rowNorm(pullForces)-desiredForce;
metrics.rmsPullError=rms(metrics.pullErrors);
metrics.rmsViewErrors=rms(pullForcesEst-desiredForce);


if plotOption
    figure
    plot((dataStruct.force_gt.time-dataStruct.force_gt.time(1))/1E9,rowNorm(dataStruct.force_gt.data))
    hold on
    plot((dataStruct.force_gt.time-dataStruct.force_gt.time(1))/1E9,dataStruct.force_gt.data)
    vline((pullTimes(1:end)-dataStruct.force_gt.time(1))/1E9,'k')
    hline(desiredForce,'r')
%     vline( (dataStruct.buttons.camera.time(logical([dataStruct.buttons.camera.push]))-dataStruct.force_gt.time(1))/1E9 )
%     vline((dataStruct.string_status.time-dataStruct.force_gt.time(1))/1E9,'g' )
    legend('Pull Force','X','Y','Z') 
    xlabel('Experiment Time')
    ylabel('Applied Force')
    prettyFigure
end

end

