function SaveExperimentData(dataFolder,expOrgan,expName,arteryExperiments,palpationExperiments)
mkdir([dataFolder filesep 'matlab'])
for ii=arteryExperiments
    [output]=readRobTxt(dataFolder,expName{ii});
    save([dataFolder filesep 'matlab' filesep 'Output' num2str(ii)],'output')
end
for ii=palpationExperiments
    for jj=1:length(expOrgan{ii})
        output=readRobTxt(dataFolder,expName{ii}{jj});
        save([dataFolder filesep  'matlab' filesep 'Output' num2str(ii) '_' num2str(jj)],'output')
    end
end
