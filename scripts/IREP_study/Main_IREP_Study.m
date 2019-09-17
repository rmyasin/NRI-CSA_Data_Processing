clear
close all
clc

addpath('R:\Projects\NRI\User_Study\Data_Processing.git\scripts\Utilities')
addpath('R:\Robots\irep.git\SnakeForceSensing\Utilities\');
addpath(genpath(getenv('ARMA_CL')))
saveData=false;
processData=false;

%% Ground truth data
dataFolder = 'R:\Projects\NRI\User_Study\Data\IREP\GT';
load([dataFolder filesep 'GT_artery_2019-07-16'],'arteryPoints');

%% Get Ablation Data
dataFolder = 'R:\Projects\NRI\User_Study\Data\IREP';
userList=1:8;
arteryData=getIREPArteryData(dataFolder,userList,saveData);

%% Get Ablation metrics
plotOption=false;

% FS Feedback
if processData
    for ii=1:length(userList)
        userNumber=userList(ii);
        for jj=1:3
            if arteryData{ii,jj}.pathType ~= jj
                warning('Bad Data at %d, %d',ii,jj)
            end
            arteryMetrics(ii,jj)=processArteryIREP(arteryData{ii,jj},arteryPoints,plotOption);
        end
    end
    save('arteryMetrics','arteryMetrics')
else
    load('arteryMetrics')
end

% Boxplot of forces
VSForce=[arteryMetrics(:,1).forceMeanAppliedVert]';
FSForce=[arteryMetrics(:,2).forceMeanAppliedVert]';
GTForce=[arteryMetrics(:,3).forceMeanAppliedVert]';
figure
myBoxPlot({VSForce,FSForce,GTForce},{'Unaided','Estimated FB','Sensor FB'},1)
hHandle=hline(0.75,'r--');
prettyFigure
title('Palpation Forces')
ylabel('Vertical Force Applied (N)')
legend(hHandle,'Desired Force Level')
prettyFigure
saveFigPDF('StudyPalpationForces.pdf')

% Distance from center
VSDist=[arteryMetrics(:,1).meanDistance]';
FSDist=[arteryMetrics(:,2).meanDistance]';
GTDist=[arteryMetrics(:,3).meanDistance]';

% Boxplot and statistics of distance to line
figure
myBoxPlot({VSDist,FSDist,GTDist},{'Unaided','Estimated Feedback','True Feedback'})
prettyFigure
axis([0.5 3.5 0 12])
title('Line Distance')
ylabel('Distance from Line Center (mm)')
saveFigPDF('StudyPalpationDistance.pdf')

distVec=[VSDist;FSDist;GTDist];
distCat = [repmat({'Unaided'},length(VSDist),1);
    repmat({'Sensed'},length(FSDist),1);
    repmat({'Ground Truth'},length(GTDist),1)];
[p,tbl,stats]=anova1(distVec,distCat,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValDist = c(:,end)
%1,2: 0.3107
%1,3: 0.1212
%2,3: 0.8641
mean(VSDist) %4.99 mm
mean(FSDist) %4.46 mm
mean(GTDist) %4.27 mm

% Brown forsyth test shows no significant difference in variance
p=vartestn([VSDist;FSDist],[ones(size(VSDist));zeros(size(FSDist))],'TestType','BrownForsythe','display','off')  %p=0.60
p=vartestn([VSDist;GTDist],[ones(size(VSDist));zeros(size(GTDist))],'TestType','BrownForsythe','display','off')  %p=0.15
p=vartestn([FSDist;GTDist],[ones(size(FSDist));zeros(size(GTDist))],'TestType','BrownForsythe','display','off')  %p=0.37
var(VSDist) %3.5274
var(FSDist) %2.7671
var(GTDist) %1.7311

% Tukey cramer test of means - no statistically significant difference
% between *any* of the forces
forceVec=[VSForce;FSForce;GTForce];
forceCategory = [repmat({'Unaided'},length(VSForce),1);
    repmat({'Sensed'},length(FSForce),1);
    repmat({'Ground Truth'},length(GTForce),1)];

figure
[p,tbl,stats]=anova1(forceVec,forceCategory,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValForcce = c(:,end) %p>0.32
title('Palpation Forces')

% Brown forsyth test shows significance FS and GT, VS and GT, not VS and FS
p=vartestn([VSForce;FSForce],[ones(size(VSForce));zeros(size(FSForce))],'TestType','BrownForsythe','display','off')  %p=0.12
p=vartestn([VSForce;GTForce],[ones(size(VSForce));zeros(size(GTForce))],'TestType','BrownForsythe','display','off')  %p=0.0003
p=vartestn([FSForce;GTForce],[ones(size(FSForce));zeros(size(GTForce))],'TestType','BrownForsythe','display','off')  %p=0.034

% Variances of different groups
var(VSForce) % 0.05
var(FSForce) % 0.03
var(GTForce) % 0.0125

% Mean errors
mean(0.75-VSForce) %0.15
mean(0.75-FSForce) %0.13
mean(0.75-GTForce) %0.19

% Mean force applied
mean(VSForce) % 0.60
mean(FSForce) % 0.62 - slightly better than GT!
mean(GTForce) % 0.56

%% Get String data
[stringData,trainingData]=getIREPStringData(dataFolder,userList,saveData);
plotOption=false;
if processData
    for ii=1:size(stringData,1)
        userNumber=userList(ii);
        desiredForce=0.75;
        for jj=1:size(stringData,2)
            stringMetrics(ii,jj) = processStringIREP(stringData{ii,jj},desiredForce,plotOption);
        end
        save('stringMetrics','stringMetrics')
    end
else
    load('stringMetrics')
end

VSPullForce = rowNorm(vertcat(stringMetrics(:,1).stringPullForce));
FSPullForce = rowNorm(vertcat(stringMetrics(:,2).stringPullForce));
GTPullForce = rowNorm(vertcat(stringMetrics(:,3).stringPullForce));

%% Plot pulling force on string
figure
myBoxPlot({VSPullForce,FSPullForce,GTPullForce},{'Unaided','Estimated Feedback','True Feedback'},0)
hHandle=hline(0.75,'r--');
title('Pulling Forces')
ylabel('Norm Force Applied (N)')
legend(hHandle,'Desired Force Level')
prettyFigure
saveFigPDF('StudyPullingForces.pdf')

pullVec=[VSPullForce;FSPullForce;GTPullForce];
pullCategory = [repmat({'Unaided'},length(VSPullForce),1);
    repmat({'Sensed'},length(FSPullForce),1);
    repmat({'Ground Truth'},length(GTPullForce),1)];

% Plot Forces
figure
[p,tbl,stats]=anova1(pullVec,pullCategory,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValPull = c(:,end) %p< 0.0007
title('String Pull Forces')
% All groups are statistically significantly different, but the unaided has
% a better mean pulling force than pulling with the sensed force
mean(VSPullForce) % 0.865
mean(FSPullForce) % 1.07
mean(GTPullForce) % 0.759

% Mean Error (t test says significantly different, which you'd expect since
% the mean pulling force is different)
mean(abs(VSPullForce-0.75)) % 0.2455 N
mean(abs(FSPullForce-0.75)) % 0.3212 N
mean(abs(GTPullForce-0.75)) % 0.0255 N

% variances: GT 0.0014, FS 0.0059 (4x > than GT), VS 0.0911 (65x > than GT)
% All variances are statistically significantly different than one another
% easily - though we don't account for "family-wise error rate", p values
% are small so there shouldn't be a problem
p=vartestn([VSPullForce;FSPullForce],[ones(size(VSPullForce));zeros(size(FSPullForce))],'TestType','BrownForsythe','display','off')  %p<5e-12
p=vartestn([VSPullForce;GTPullForce],[ones(size(VSPullForce));zeros(size(GTPullForce))],'TestType','BrownForsythe','display','off')  %p<3e-16
p=vartestn([FSPullForce;GTPullForce],[ones(size(FSPullForce));zeros(size(GTPullForce))],'TestType','BrownForsythe','display','off')  %p<8e-7



%%
effort_IREP_study

% No significant difference in palpation effort
palpTLXVec=[effort_Palpation_FS;effort_Palpation_GT;effort_Palpation_U];
palpTLXCat = [repmat({'FS'},length(effort_Palpation_FS),1);
    repmat({'GT'},length(effort_Palpation_GT),1);
    repmat({'U'},length(effort_Palpation_U),1)];

figure
[p,tbl,stats]=anova1(palpTLXVec,palpTLXCat,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValPalpTLX = c(:,end) % p>0.43
title('Palpation Effort')
mean(effort_Palpation_FS) %10.63
mean(effort_Palpation_GT) % 8.5
mean(effort_Palpation_U) % 12.88

% String Effort - unaided is significantly more difficult than the other
% tasks
stringTLXVec= [effort_String_FS;effort_String_GT;effort_String_U];
stringTLXCat = [repmat({'FS'},length(effort_String_FS),1);
    repmat({'GT'},length(effort_String_GT),1);
    repmat({'U'},length(effort_String_U),1)];

figure
[p,tbl,stats]=anova1(stringTLXVec,stringTLXCat,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValStringTLX = c(:,end) %0.46,0.02,0.002
title('String Effort')
mean(effort_String_FS) % 5.25
mean(effort_String_GT) % 1.88
mean(effort_String_U) % 13.25




%%
ablateAuto={
    'Intrinsic20190812AblateBeta0Repeat'
    'Intrinsic20190812AblateBeta1Repeat'
    };
fDat1= getExperimentFScope(ablateAuto{1});
fDat2= getExperimentFScope(ablateAuto{2});

plotOption=true;
output = processArteryIREP_fDat(fDat1,arteryPoints,plotOption);
output2 = processArteryIREP_fDat(fDat2,arteryPoints,plotOption);


%%
forceVec=[VSForce;FSForce;GTForce];
forceCategory = [repmat({'Unaided'},length(VSForce),1);
    repmat({'Estimated'},length(FSForce),1);
    repmat({'Sensor'},length(GTForce),1)];

figure
[p,tbl,stats]=anova1(forceVec,forceCategory,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValForcce = c(:,end) %p>0.3165
title('Ablation Forces')

% Brown forsyth test shows significance FS and GT, VS and GT, not VS and FS
p=vartestn([VSForce;FSForce],[ones(size(VSForce));zeros(size(FSForce))],'TestType','BrownForsythe','display','off')  %p=0.12
p=vartestn([VSForce;GTForce],[ones(size(VSForce));zeros(size(GTForce))],'TestType','BrownForsythe','display','off')  %p=0.0003
p=vartestn([FSForce;GTForce],[ones(size(FSForce));zeros(size(GTForce))],'TestType','BrownForsythe','display','off')  %p=0.034

% Variances of different groups
var(VSForce) % 0.05
var(FSForce) % 0.03
var(GTForce) % 0.0125
var(output2.meanAppliedVerticalForce) % 0.0014

% Mean errors
mean(0.75-VSForce) %0.15
mean(0.75-FSForce) %0.13
mean(0.75-GTForce) %0.19
mean(0.75-output2.meanAppliedVerticalForce) % 0.081

% Mean force applied
mean(VSForce) % 0.60
mean(FSForce) % 0.62 - slightly better than GT!
mean(GTForce) % 0.56
mean(output2.meanAppliedVerticalForce) % 0.67

%%
ablateB0=getExperimentFScope('Intrinsic20190813MagAblateB0');
ablateB1=getExperimentFScope('Intrinsic20190813MagAblateB1');
ablateB0Output = processArteryIREP_fDat(ablateB0,arteryPoints,plotOption);
%
ablateB1Output = processArteryIREP_fDat(ablateB1,arteryPoints,plotOption);

ablateB1Output



%% Redo box plots and t tests with automated ablation
myBoxPlot({VSForce,FSForce,GTForce,ablateB1Output.meanAppliedVerticalForce},{'Unaided','JEXSIS FB','Sensor FB','Automated'},1)
hHandle=hline(0.75,'r--');
prettyFigure
set(hHandle,'LineWidth',3)
title('Palpation Forces')
ylabel('Vertical Force Applied (N)')
legend(hHandle,'Desired Force Level')
saveFigPDF('StudyPalpationForcesAuto.pdf')

% Variance is significantly lower
forceAutoVec=[VSForce',FSForce',GTForce',ablateB1Output.meanAppliedVerticalForce];
forceAutoVec=abs([VSForce',FSForce',GTForce',ablateB1Output.meanAppliedVerticalForce]-0.75);
forceAutoCat = [repmat({'Unaided'},length(VSForce),1);
    repmat({'Sensed'},length(FSForce),1);
    repmat({'Ground Truth'},length(GTForce),1);
    repmat({'Automated'},length(ablateB1Output.meanAppliedVerticalForce),1)];
[p,tbl,stats]=anova1(forceAutoVec,forceAutoCat,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');

var(GTForce)

var(ablateB1Output.meanAppliedVerticalForce)

% Variance is significantly lower
p=vartestn([VSForce;ablateB1Output.meanAppliedVerticalForce'],[ones(size(VSForce));zeros(size(ablateB1Output.meanAppliedVerticalForce'))],'TestType','BrownForsythe','display','off')  %p=6.5e-7
p=vartestn([FSForce;ablateB1Output.meanAppliedVerticalForce'],[ones(size(FSForce));zeros(size(ablateB1Output.meanAppliedVerticalForce'))],'TestType','BrownForsythe','display','off')  %p=8.8e-6
p=vartestn([GTForce;ablateB1Output.meanAppliedVerticalForce'],[ones(size(GTForce));zeros(size(ablateB1Output.meanAppliedVerticalForce'))],'TestType','BrownForsythe','display','off')  %p=3.5e-7

save('allIREPData')