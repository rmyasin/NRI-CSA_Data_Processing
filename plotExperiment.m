function plotExperiment(dataFolder,filenames)
if ~iscell(filenames)
    filenames={filenames};
end
baseLabel=60; %Automatically apply base frame offset using label 60
a=load('tip_calibration'); % Read tip and marker calibration

for ii=1:length(filenames)
    [cur(ii),des(ii),micron]=readRobTxt(dataFolder,filenames{ii},baseLabel); % Read the raw data and apply base offset
    tipTotal(ii)=getMicronTip(micron,a); % Get Tip Pose
end

%% Find fiducial locations in each experiment
for ii=1:length(filenames)
    figure(ii)
    plot(tipTotal(ii).tip')
    hold on;
    plot((tipTotal(ii).time-mean(tipTotal(ii).time))/10^10*5)
end

end