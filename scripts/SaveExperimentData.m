function SaveExperimentData(dataFolder,expOrgan,expName,arteryExperiments,palpationExperiments)
mkdir([dataFolder filesep 'matlab'])
for ii=arteryExperiments
    for jj=1:length(expName{ii})
        [output]=readRobTxt(dataFolder,expName{ii}{jj});
        if jj>1
            save([dataFolder filesep 'matlab' filesep 'Output' num2str(ii) '_' num2str(jj)],'output')
        else
            save([dataFolder filesep 'matlab' filesep 'Output' num2str(ii)],'output')
        end
    end
end
for ii=palpationExperiments
    for jj=1:length(expOrgan{ii})
        output=readRobTxt(dataFolder,expName{ii}{jj});
        save([dataFolder filesep  'matlab' filesep 'Output' num2str(ii) '_' num2str(jj)],'output')
    end
end
