% plot boxplots and calculate p values for all palpation experiments
function plotPalpationStatistics(palpationMetrics)
timeVec=[[palpationMetrics(:,1).completionTime]';[palpationMetrics(:,2).completionTime]'];
timeCategory = [repmat({'Haptic'},length([palpationMetrics(:,1).completionTime]),1);
                    repmat({'Visual'},length([palpationMetrics(:,2).completionTime]),1)];

timeCell={[palpationMetrics(:,1).completionTime],[palpationMetrics(:,2).completionTime]};

% How many spheres were found
foundHaptic=([palpationMetrics(:,1).spheresFound])./[palpationMetrics(:,1).spheresTotal];
foundGP=([palpationMetrics(:,2).spheresFound])./[palpationMetrics(:,2).spheresTotal];
foundCell={foundHaptic,foundGP};
foundHaptic=([palpationMetrics(:,1).spheresFoundCenter])./[palpationMetrics(:,1).spheresTotal];
foundGP=([palpationMetrics(:,2).spheresFoundCenter])./[palpationMetrics(:,2).spheresTotal];
foundCellCenter={foundHaptic,foundGP};

% How many extra spheres were found
extraHaptic=([palpationMetrics(:,1).extraSelect]);
extraGP=([palpationMetrics(:,2).extraSelect]);
extraCell={extraHaptic,extraGP};
extraHaptic=([palpationMetrics(:,1).extraSelectCenter]);
extraGP=([palpationMetrics(:,2).extraSelectCenter]);
extraCellCenter={extraHaptic,extraGP};

% Distances for "found" tumors
tmp=[palpationMetrics(:,1).closeDist];
closeDistHaptic=vertcat(tmp{:});
tmp=[palpationMetrics(:,2).closeDist];
closesDistGP=vertcat(tmp{:});
closeCell={closeDistHaptic,closesDistGP};

tmp=[palpationMetrics(:,1).closeDistCenter];
closeDistHaptic=vertcat(tmp{:});
tmp=[palpationMetrics(:,2).closeDistCenter];
closesDistGP=vertcat(tmp{:});
closeCellCenter={closeDistHaptic,closesDistGP};

distVec=[closeCellCenter{1};closeCellCenter{2}];
distCategory = [repmat({'Haptic'},length(closeCellCenter{1}),1);
                    repmat({'Visual'},length(closeCellCenter{2}),1)];

% Feature distances
tmp=[palpationMetrics(:,1).distanceList];
distanceHaptic=vertcat(tmp{:});
tmp=[palpationMetrics(:,2).distanceList];
distanceGP=vertcat(tmp{:});
distanceCell={distanceHaptic,distanceGP};

% Feature center distances
tmp=[palpationMetrics(:,1).centerDistances];
distanceHapticCenter=vertcat(tmp{:});
tmp=[palpationMetrics(:,2).centerDistances];
distanceGPCenter=vertcat(tmp{:});
distanceCenterCell={distanceHapticCenter,distanceGPCenter};
%% Plot Artery Results (boxplots)
expNames={'Force FB','Visual FB'};
% 
% figure
% myBoxPlot(foundCell,expNames)
% title('Percent of Tumors Found')
% ylabel('Percent Found')
% prettyFigure

figure
myBoxPlot(foundCellCenter,expNames)
title('Percent of Tumors Found')
ylabel('Percent Found')
prettyFigure


% figure
% myBoxPlot(extraCell,expNames)
% title('Extra Tumors Found')
% ylabel('Number Additional Selected')
% yticks(0:max([extraCell{:}]))
% prettyFigure

figure
myBoxPlot(extraCellCenter,expNames)
title('Extra Tumors Found')
ylabel('Number Additional Selected')
yticks(0:max([extraCellCenter{:}]))
prettyFigure

fig = figure;
left_color = [0 0 0];
right_color = [0 0 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

myBoxPlot([foundCellCenter,extraCellCenter{1}/10,extraCellCenter{2}/10],[expNames expNames])
prettyFigure
ylim([-0.1 1.1])
y=get(gca,'ylim');
hold on
plot([2.5,2.5],y,'k','linewidth',4)
ylabel('Percent Found')
yyaxis right
ylim([-1 11])
title(['Palpation Performance' newline])
hYLabel=ylabel('Number Selected','Color','k');
% hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',90,'VerticalAlignment','middle')
text(1,11.65,'Features Found','FontSize',32,'Color','r','FontAngle','oblique')
text(3,11.65,'Excess Features','FontSize',32,'Color','r','FontAngle','oblique')


figure
myBoxPlot(timeCell,expNames)
title('Experiment Time')
ylabel('Completion Time (s)')
prettyFigure

% Plot raw distances from selected points to closest tumor
% figure
% myBoxPlot(distanceCell,expNames)
% title('Distance Surf')
% ylabel('Distance to Points (s)')
% prettyFigure
% 
% figure
% myBoxPlot(distanceCenterCell,expNames)
% title('Distance Center')
% ylabel('Distance to Points (s)')
% prettyFigure

%% ANOVA analysis
figure
[p,tbl,stats]=anova1(timeVec,timeCategory,'off');
c=multcompare(stats)
title('Completion Time')

figure
[p,tbl,stats]=anova1(distVec,distCategory,'off');
c=multcompare(stats)
title('Distance From GT')


end
