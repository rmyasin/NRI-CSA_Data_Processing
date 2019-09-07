
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
figure
myBoxPlot({VSPullForce,FSPullForce,GTPullForce,VSForce,FSForce,GTForce,...
    ablateB1Output.meanAppliedVerticalForce},...
    {'None','JEFS','Sensor',...
    'None','JEFS','Sensor','Auto'},1,1)
hHandle=hline(0.75,'r--');
vHandle=vline(3.5,'k');
prettyFigure
set(hHandle,'LineWidth',3)
set(vHandle,'LineWidth',3)
title(['Interaction Forces' newline])
ylabel('Vertical Force Applied (N)')
legend(hHandle,'Desired Force Level')
text(1,1.8,'Knot Tightening','FontSize',32,'Color','r','FontAngle','oblique')
text(5,1.8,'Ablation','FontSize',32,'Color','r','FontAngle','oblique')
text(3,-.02,'Force Source','FontSize',26,'Color',[0.2 0.2 0.2])
saveFigPDF(['IREP_Forces']);