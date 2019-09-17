
figure
myBoxPlot({VSPullForce,FSPullForce,GTPullForce},{'Unaided','Estimated Feedback','True Feedback'},0)
hHandle=hline(0.75,'r--');
title('Pulling Forces')
ylabel('Norm Force Applied (N)')
legend(hHandle,'Desired Force Level')
prettyFigure

%%

figure
myBoxPlot({VSForce,FSForce,GTForce,ablateB1Output.meanAppliedVerticalForce},{'Unaided','JEXSIS FB','Sensor FB','Automated'},1)
hHandle=hline(0.75,'r--');
prettyFigure
set(hHandle,'LineWidth',3)
title('Palpation Forces')
ylabel('Vertical Force Applied (N)')
legend(hHandle,'Desired Force Level')

%%
fDat=getExperimentFScope('IntrinsicString20190913Beta1Vert');
fallingIndex=diff(fDat.FCMD(:,8))<0;
testIndex=find(fallingIndex)-1;
autoForce=fDat.WRENCH_measured(testIndex,2);

fDatB1=getExperimentFScope('IntrinsicString20190913Beta1VertII');
fallingIndex=diff(fDatB1.FCMD(:,8))<0;
testIndex=find(fallingIndex)-1;
autoForce=[autoForce;fDatB1.WRENCH_measured(testIndex,2)];
% errListY=rowNorm(-fDatB1.FCMD(testIndex,8)-fDatB1.WRENCH_measured(testIndex,2));

figure
myBoxPlot({VSForce,FSForce,GTForce,ablateB1Output.meanAppliedVerticalForce,...
    VSPullForce,FSPullForce,GTPullForce,autoForce},...
    {'None','JEFS','Sensor','Auto',...
    'None','JEFS','Sensor','Auto'},1,1);
hHandle=hline(0.75,'r--');
vHandle=vline(4.5,'k');
prettyFigure %Change line 32: set(series_handle(index),'markersize',10.0);
set(hHandle,'LineWidth',3)
set(vHandle,'LineWidth',3)
title(['Interaction Forces' newline])
ylabel('Vertical Force Applied (N)')
legend(hHandle,'Desired Force Level','Location','NorthWest')
text(2,1.8,'Ablation','FontSize',32,'Color','r','FontAngle','oblique')
text(5,1.8,'Knot Tightening','FontSize',32,'Color','r','FontAngle','oblique')
text(3,-.04,'Force Source','FontSize',26,'Color',[0.2 0.2 0.2],'FontWeight','bold')
saveFigPDF(['IREP_Forces_Auto']);


pullVec=[VSPullForce;FSPullForce;GTPullForce;autoForce];
pullCat = [repmat({'Unaided'},length(VSPullForce),1);
    repmat({'JEFS'},length(FSPullForce),1);
    repmat({'Sensor'},length(GTPullForce),1);
    repmat({'Auto'},length(autoForce),1)];
[p,tbl,stats]=anova1(pullVec,pullCat,'off');
figure
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValKnot = c(:,end) %p<0.007 except for sensor and auto, p=
title('Ablation Forces')

var(VSPullForce) % 0.0911
var(FSPullForce) % 0.0059
var(GTPullForce) % 0.0014
var(autoForce)   % 0.0026

p=vartestn([VSPullForce;FSPullForce],[ones(size(VSPullForce));zeros(size(FSPullForce))],'TestType','BrownForsythe','display','off')  %4.5383e-12
p=vartestn([VSPullForce;GTPullForce],[ones(size(VSPullForce));zeros(size(GTPullForce))],'TestType','BrownForsythe','display','off')  %2.8604e-16
p=vartestn([VSPullForce;autoForce],[ones(size(VSPullForce));zeros(size(autoForce))],'TestType','BrownForsythe','display','off')  %1.1251e-08
p=vartestn([FSPullForce;GTPullForce],[ones(size(FSPullForce));zeros(size(GTPullForce))],'TestType','BrownForsythe','display','off')  %7.9137e-07
p=vartestn([FSPullForce;autoForce],[ones(size(FSPullForce));zeros(size(autoForce))],'TestType','BrownForsythe','display','off')  %0.0130
p=vartestn([GTPullForce;autoForce],[ones(size(GTPullForce));zeros(size(autoForce))],'TestType','BrownForsythe','display','off')  %0.1998
