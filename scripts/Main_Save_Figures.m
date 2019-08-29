clear
close all
clc

%% Plot statistics
load('arteryMetrics')
plotArteryStatistics(arteryMetrics)

figoutput='R:\Projects\NRI\User_Study\Data_Processing.git\figs';

saveFigPDF([figoutput filesep 'Path_Coverage_Bar'],1);
saveFigPDF([figoutput filesep 'Path_Distance_Bar'],2);
saveFigPDF([figoutput filesep 'Path_Force_Bar'],3);
saveFigPDF([figoutput filesep 'Path_Time_Bar'],4);

load('palpationMetrics')
plotPalpationStatistics(palpationMetrics)

saveFigPDF([figoutput filesep 'Palp_Found'],9);
saveFigPDF([figoutput filesep 'Palp_Extra'],10);
saveFigPDF([figoutput filesep 'Palp_Feature_Bar'],11);
saveFigPDF([figoutput filesep 'Palp_Time_Bar'],12);


Effort
saveFigPDF([figoutput filesep 'User_Effort'],17);


%% Output answers
disp('Total Time')
mean([arteryMetrics(:,1).completionTime])
mean([arteryMetrics(:,2).completionTime])
mean([arteryMetrics(:,3).completionTime])
mean([arteryMetrics(:,4).completionTime])

disp('Lateral Following Error')
mean([arteryMetrics(:,1).meanProjDistance])
mean([arteryMetrics(:,2).meanProjDistance])
mean([arteryMetrics(:,3).meanProjDistance])
mean([arteryMetrics(:,4).meanProjDistance])

disp('Coverage:')
mean([arteryMetrics(:,1).coverage])
mean([arteryMetrics(:,2).coverage])
mean([arteryMetrics(:,3).coverage])
mean([arteryMetrics(:,4).coverage])

disp('Force Regulation Errors:')
forceErrors=[arteryMetrics(:,1).forceError];
mean(forceErrors(~isnan(forceErrors)))
mean([arteryMetrics(:,2).forceError])
mean([arteryMetrics(:,3).forceError])
mean([arteryMetrics(:,4).forceError])


%%
disp('Found Percentage')
foundHaptic=([palpationMetrics(:,1).spheresFoundCenter])./[palpationMetrics(:,1).spheresTotal];
foundGP=([palpationMetrics(:,2).spheresFoundCenter])./[palpationMetrics(:,2).spheresTotal];
mean(foundHaptic(~isnan(foundHaptic)))
mean(foundGP(~isnan(foundGP)))

disp('Extra features')
extraHaptic=([palpationMetrics(:,1).extraSelectCenter]);
extraGP=([palpationMetrics(:,2).extraSelectCenter]);
mean(extraHaptic(~isnan(extraHaptic)))
mean(extraGP(~isnan(extraGP)))

disp('Palpation Time')
mean([palpationMetrics(:,1).completionTime])
mean([palpationMetrics(:,2).completionTime])


