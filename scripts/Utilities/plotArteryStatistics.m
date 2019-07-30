function plotArteryStatistics(arteryMetrics)
coverageVec=[[arteryMetrics(:,1).coverage]';[arteryMetrics(:,2).coverage]';[arteryMetrics(:,3).coverage]';[arteryMetrics(:,4).coverage]'];
coverageCategory = [repmat({'Unaided'},length([arteryMetrics(:,1).coverage]),1);
                    repmat({'Visual'},length([arteryMetrics(:,2).coverage]),1);
                    repmat({'Haptic VF'},length([arteryMetrics(:,3).coverage]),1);
                    repmat({'Auto VF'},length([arteryMetrics(:,4).coverage]),1)];
coverageCell={[arteryMetrics(:,1).coverage],[arteryMetrics(:,2).coverage],[arteryMetrics(:,3).coverage],[arteryMetrics(:,4).coverage]};

distProjVec=[[arteryMetrics(:,1).meanProjDistance]';[arteryMetrics(:,2).meanProjDistance]';[arteryMetrics(:,3).meanProjDistance]';[arteryMetrics(:,4).meanProjDistance]']*1000;
distProjCategory = [repmat({'Unaided'},length([arteryMetrics(:,1).meanProjDistance]),1);
                    repmat({'Visual'},length([arteryMetrics(:,2).meanProjDistance]),1);
                    repmat({'Haptic VF'},length([arteryMetrics(:,3).meanProjDistance]),1);
                    repmat({'Auto VF'},length([arteryMetrics(:,4).meanProjDistance]),1)];
distProjCell={[arteryMetrics(:,1).meanProjDistance]*1000,[arteryMetrics(:,2).meanProjDistance]*1000,[arteryMetrics(:,3).meanProjDistance]*1000,[arteryMetrics(:,4).meanProjDistance]*1000};

forceVec=[[arteryMetrics(:,1).forceError]';[arteryMetrics(:,2).forceError]';[arteryMetrics(:,3).forceError]';[arteryMetrics(:,4).forceError]'];
forceCategory = [repmat({'Unaided'},length([arteryMetrics(:,1).forceError]),1);
                    repmat({'Visual'},length([arteryMetrics(:,2).forceError]),1);
                    repmat({'Haptic VF'},length([arteryMetrics(:,3).forceError]),1);
                    repmat({'Auto VF'},length([arteryMetrics(:,4).forceError]),1)];
forceCell={[arteryMetrics(:,1).forceError],[arteryMetrics(:,2).forceError],[arteryMetrics(:,3).forceError],[arteryMetrics(:,4).forceError]};

timeVec=[[arteryMetrics(:,1).completionTime]';[arteryMetrics(:,2).completionTime]';[arteryMetrics(:,3).completionTime]';[arteryMetrics(:,4).completionTime]'];
timeCategory = [repmat({'Unaided'},length([arteryMetrics(:,1).completionTime]),1);
                    repmat({'Visual'},length([arteryMetrics(:,2).completionTime]),1);
                    repmat({'Haptic VF'},length([arteryMetrics(:,3).completionTime]),1);
                    repmat({'Auto VF'},length([arteryMetrics(:,4).completionTime]),1)];
timeCell={[arteryMetrics(:,1).completionTime],[arteryMetrics(:,2).completionTime],[arteryMetrics(:,3).completionTime],[arteryMetrics(:,4).completionTime]};

%% Plot Artery Results
expNames={'Unaided','Visual','Haptic VF','Auto VF'};
figure
myBoxPlot(coverageCell,expNames)
title('Path Contact Coverage')
ylabel('Coverage Percentage')
prettyFigure
y=get(gca,'ylim');
hold on
plot([1.5,1.5],y,'k','linewidth',4)

figure
myBoxPlot(distProjCell,expNames)
title('Projected Path-Following Error')
ylabel('Mean Distance from Path (mm)')
prettyFigure
y=get(gca,'ylim');
hold on
plot([1.5,1.5],y,'k','linewidth',4)
plot([2.5,2.5],y,'k','linewidth',4)

figure
myBoxPlot(forceCell,expNames)
title('Force Errors')
ylabel('Difference in Norm Force (N)')
prettyFigure
y=get(gca,'ylim');
hold on
plot([1.5,1.5],y,'k','linewidth',4)
plot([3.5,3.5],y,'k','linewidth',4)

figure
myBoxPlot(timeCell,expNames)
title('Experiment Time')
ylabel('Completion Time (s)')
prettyFigure
y=get(gca,'ylim');
hold on
plot([3.5,3.5],y,'k','linewidth',4)

%% ANOVA analysis
figure
[p,tbl,stats]=anova1(coverageVec,coverageCategory,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValCoverage = c(:,end)
title('Path Contact Coverage')

figure
[p,tbl,stats]=anova1(distProjVec,distProjCategory,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValDist = c(:,end)
title('Projected Path-Following Error')

figure
[p,tbl,stats]=anova1(forceVec,forceCategory,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValForce = c(:,end)
title('Force Errors')

figure
[p,tbl,stats]=anova1(timeVec,timeCategory,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValTime = c(:,end)
title('Completion Time')

end
