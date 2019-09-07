% Save mat files for data of a given user trial
% Inputs:
% dataFolder - folder data is saved in (will save mat files here)
% expOrgan - cell list with labels of organs to process
% expName - cell array with names of experiments to process
% arteryExperiments - array of which ablation experiments to process
% palpationExperiments - array of which palpation experiments to process

function SaveExperimentData(dataFolder,expOrgan,expName,arteryExperiments,palpationExperiments)
mkdir([dataFolder filesep 'matlab'])

% Read and save ablation data
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

% Read and save palpation data
for ii=palpationExperiments
    for jj=1:length(expOrgan{ii})
        output=readRobTxt(dataFolder,expName{ii}{jj});
        save([dataFolder filesep  'matlab' filesep 'Output' num2str(ii) '_' num2str(jj)],'output')
    end
end
