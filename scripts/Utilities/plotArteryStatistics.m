function plotArteryStatistics(arteryMetrics)
for ii=1:4
    arteryStatistics.coverage(ii) = mean([arteryMetrics(:,ii).coverage]);
    arteryStatistics.meanDistance(ii) = mean([arteryMetrics(:,ii).meanDistance]);
    arteryStatistics.meanProjDistance(ii) = mean([arteryMetrics(:,ii).meanProjDistance]);
    arteryStatistics.forceError(ii) = mean([arteryMetrics(:,ii).forceError]);
    arteryStatistics.time(ii) = mean([arteryMetrics(:,ii).completionTime]);
end

coverageMat=[[arteryMetrics(:,1).coverage]',[arteryMetrics(:,2).coverage]',[arteryMetrics(:,3).coverage]',[arteryMetrics(:,4).coverage]'];
coverageCell={[arteryMetrics(:,1).coverage],[arteryMetrics(:,2).coverage],[arteryMetrics(:,3).coverage],[arteryMetrics(:,4).coverage]};

distMat=[[arteryMetrics(:,1).meanDistance]',[arteryMetrics(:,2).meanDistance]',[arteryMetrics(:,3).meanDistance]',[arteryMetrics(:,4).meanDistance]'];
distCell={[arteryMetrics(:,1).meanDistance],[arteryMetrics(:,2).meanDistance],[arteryMetrics(:,3).meanDistance],[arteryMetrics(:,4).meanDistance]};

distProjMat=[[arteryMetrics(:,1).meanProjDistance]',[arteryMetrics(:,2).meanProjDistance]',[arteryMetrics(:,3).meanProjDistance]',[arteryMetrics(:,4).meanProjDistance]'];
distProjCell={[arteryMetrics(:,1).meanProjDistance],[arteryMetrics(:,2).meanProjDistance],[arteryMetrics(:,3).meanProjDistance],[arteryMetrics(:,4).meanProjDistance]};

forceMat=[[arteryMetrics(:,1).forceError]',[arteryMetrics(:,2).forceError]',[arteryMetrics(:,3).forceError]',[arteryMetrics(:,4).forceError]'];
forceCell={[arteryMetrics(:,1).forceError],[arteryMetrics(:,2).forceError],[arteryMetrics(:,3).forceError],[arteryMetrics(:,4).forceError]};

timeMat=[[arteryMetrics(:,1).completionTime]',[arteryMetrics(:,2).completionTime]',[arteryMetrics(:,3).completionTime]',[arteryMetrics(:,4).completionTime]'];
timeCell={[arteryMetrics(:,1).completionTime],[arteryMetrics(:,2).completionTime],[arteryMetrics(:,3).completionTime],[arteryMetrics(:,4).completionTime]};

%% Plot Artery Results
expNames={'Unaided','Visual','Haptic VF','Auto VF'};
figure
myBoxPlot(coverageCell,expNames)
title('Path Contact Coverage')
ylabel('Coverage Percentage')
prettyFigure

figure
myBoxPlot(distCell,expNames)
title('Path-Following Error')
ylabel('Mean Distance from Path (mm)')
prettyFigure

figure
myBoxPlot(distProjCell,expNames)
title('Projected Path-Following Error')
ylabel('Mean Distance from Path (mm)')
prettyFigure

figure
myBoxPlot(forceCell,expNames)
title('Force Errors')
ylabel('Difference in Norm Force (N)')
prettyFigure

figure
myBoxPlot(timeCell,expNames)
title('Experiment Time')
ylabel('Completion Time (s)')
prettyFigure

%% ANOVA analysis
figure
[p,tbl,stats]=anova1(coverageMat,expNames,'off');
multcompare(stats)
title('Path Contact Coverage')

figure
[p,tbl,stats]=anova1(distMat,expNames,'off');
multcompare(stats)
title('Path-Following Error')

figure
[p,tbl,stats]=anova1(distProjMat,expNames,'off');
multcompare(stats)
title('Projected Path-Following Error')

figure
[p,tbl,stats]=anova1(forceMat,expNames,'off');
multcompare(stats)
title('Force Errors')

figure
[p,tbl,stats]=anova1(timeMat,expNames,'off');
multcompare(stats)
title('Completion Time')

end
