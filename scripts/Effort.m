Effort_Ablation1=[12
19
14
15
21
16
16
16
19
17
15
27
22
25
14
16
27
16
10
18
19
15
22
19
12
12];

Effort_Ablation2=[13
8
5
14
15
12
10
12
16
13
17
17
17
15
20
12
27
13
9
12
18
22
26
13
7
16
];

Effort_Ablation3=[8
10
15
10
16
9
10
21
16
20
16
12
17
10
17
17
22
12
6
15
15
26
26
9
5
14
];

Effort_Ablation4=[1
1
5
9
4
3
5
23
6
4
15
8
14
6
12
14
19
12
4
12
12
15
20
10
2
8
];

Effort_Palpation1=[20
25
17
15
24
18
21
20
17
16
19
24
20
16
24
17
22
13
12
20
21
25
19
5
16
11
];

Effort_Palpation2=[7
6
3
14
16
14
13
16
15
14
12
15
20
17
16
23
11
9
11
14
27
24
-1
9
7
];


ablationVec=[Effort_Ablation1;Effort_Ablation2;Effort_Ablation3;Effort_Ablation4];
ablationCell={Effort_Ablation1,Effort_Ablation2,Effort_Ablation3,Effort_Ablation4};
ablationCategory = [repmat({['Unaided']},length(ablationCell{1}),1);
                    repmat({['Visual']},length(ablationCell{2}),1);
                    repmat({['Haptic VF']},length(ablationCell{3}),1);
                    repmat({['Auto VF']},length(ablationCell{4}),1)];
% figure
% myBoxPlot(ablationCell,ablationCategory)
% title('Perceived User Ablation Effort')
% ylabel('Combined TLX Effort Score')
% prettyFigure

figure
[p,tbl,stats]=anova1(ablationVec,ablationCategory,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValAblation = c(:,end)


palpationVec=[Effort_Palpation1;Effort_Palpation2];
palpationCell={Effort_Palpation1,Effort_Palpation2};
palpationCategory = [repmat({['Haptic']},length(palpationCell{1}),1);
                    repmat({['Visual']},length(palpationCell{2}),1)];
% figure
% myBoxPlot(palpationCell,palpationCategory)
% title('Perceived User Palpation Effort')
% ylabel('Combined TLX Effort Score')
% prettyFigure

figure
[p,tbl,stats]=anova1(palpationVec,palpationCategory,'off');
c=multcompare(stats,'Alpha',0.05,'CType','tukey-kramer');
pValPalpation = c(:,end)

%%
figure
myBoxPlot(horzcat(ablationCell,palpationCell),vertcat(ablationCategory,palpationCategory))
% [15.5000 2.5160]
% annotation('textbox',[.9 .5 .1 .2],'String','Text outside the axes','EdgeColor','none')
ylabel('Combined TLX Effort Score')
prettyFigure
hold on
y=get(gca,'ylim');
plot([4.5,4.5],y,'k','linewidth',4)
title(['Perceived User Effort' newline])
text(2,30,'Ablation','FontSize',32,'Color','r','FontAngle','oblique')
text(5,30,'Palpation','FontSize',32,'Color','r','FontAngle','oblique')
plot(3.75,3.25,'kp','MarkerSize',15,'MarkerFaceColor','k')
plot(5.75,8.35,'kp','MarkerSize',15,'MarkerFaceColor','k')

