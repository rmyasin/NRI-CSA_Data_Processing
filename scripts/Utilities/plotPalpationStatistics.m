function plotPalpationStatistics(palpationMetrics)

% for ii=1:2
%     palpationStatistics.time(ii) = mean([palpationMetrics(:,ii).completionTime]);
% end

timeMat=[[palpationMetrics(:,1).completionTime]',[palpationMetrics(:,2).completionTime]'];
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

tmp=[palpationMetrics(:,1).distanceList];
distanceHaptic=vertcat(tmp{:});
tmp=[palpationMetrics(:,2).distanceList];
distanceGP=vertcat(tmp{:});
distanceCell={distanceHaptic,distanceGP};


tmp=[palpationMetrics(:,1).centerDistances];
distanceHapticCenter=vertcat(tmp{:});
tmp=[palpationMetrics(:,2).centerDistances];
distanceGPCenter=vertcat(tmp{:});
distanceCenterCell={distanceHapticCenter,distanceGPCenter};
%% Plot Artery Results
expNames={'Haptic','Visual GP'};
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

% 
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

% figure
% myBoxPlot(closeCell,expNames)
% title('Distance Surf')
% ylabel('Distance to Points (s)')
% prettyFigure

figure
myBoxPlot(closeCellCenter,expNames)
title('Distance from Ground Truth')
ylabel('Distance to Points (mm)')
prettyFigure

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
% 
% figure
% [p,tbl,stats]=anova1(timeMat,expNames,'off');
% multcompare(stats)
% title('Completion Time')

end
