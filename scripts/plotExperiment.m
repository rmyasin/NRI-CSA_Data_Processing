function plotExperiment(dataFolder,filenames)
if ~iscell(filenames)
    filenames={filenames};
end
baseLabel=60; %Automatically apply base frame offset using label 60
a=load('tip_calibration'); % Read tip and marker calibration

for ii=1:length(filenames)
    [cur(ii),des(ii),micron,joint,version,tipLoc]=readRobTxt(dataFolder,filenames{ii},baseLabel); % Read the raw data and apply base offset
    if ~isempty(micron)
        tipTotal(ii)=getMicronTip(micron,a); % Get Tip Pose
    end
end

%% Find fiducial locations in each experiment
minTime=min(cur(1).time);

if ~isempty(micron)
    for ii=1:length(filenames)
        figure(ii)
        plot(tipTotal(ii).tip')
        hold on;
        plot((tipTotal(ii).time-minTime)/10^9)
        title(['Marker ' num2str(ii)])
    end
else
    plot((tipLoc.time-minTime)/10^9,tipLoc.pos);
    title('Micron Position')
end

for ii=1:length(des)
    figure
    plot((des(ii).time-minTime)/10^9,des(ii).pos)
    title('Robot Position')
end

end