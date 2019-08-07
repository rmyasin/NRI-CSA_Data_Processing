function arteryInRobot = getArteryIREP(experimentName)
beginning=[-15;30;120]/1000';
finish=[0;20;175]/1000';

for ii=1:3
    arteryInRobot(:,ii)=linspace(beginning(ii),finish(ii),200);
end
end