function metrics = processPalpationExperiment(dataFolder,ii,expOrgan,regTimes,regNames,plotOption)
cpd_dir=getenv('CPDREG');
featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];
organFolder=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];

    for jj=1:length(expOrgan{ii})
        % Read in organ, get ground truth location of organ/spheres
        organLabel=expOrgan{ii}{jj};
        figure
        
        % Read data file
        load([dataFolder filesep 'Output' num2str(ii) '_' num2str(jj)],'output');
        cur=output.psm_cur;
        micronTip=output.micronTip;

        % Find the most recent registration
        registrationIndex=find((cur.time(1)-regTimes)>0,1,'last');
        regFolder=regNames{registrationIndex};

        % Get Sphere Points
        [spheresInRobot,H1,sphereRaw] = getSpherePoints([dataFolder filesep regFolder],organLabel,featureFolder);

        % Get selected POI times
        savedPoints=output.display_points.data{end}';

        % Get Organ Points
        [organInRobot,H2,organRaw] = getOrganPoints([dataFolder filesep regFolder],organLabel,organFolder);

        if plotOption
            % Plot results
            vplot3(organInRobot')
            hold on
            vplot3(spheresInRobot','o')
            vplot3(savedPoints,'x')
        end
        registrationFilePath = [dataFolder filesep regFolder filesep 'Micron2Phantom' num2str(label2num(organLabel)) '.txt'];
        HMicron=readTxtReg(registrationFilePath);
        micronHomog=H2*(HMicron\[micronTip.pos';ones(1,length(micronTip.pos))]);
        vplot3(micronHomog(1:3,:)');

        %     TODO: need to convert robot selected points to closest on
        %     organ and then distance to the sphere center (which I think we've
        %     maybe already converted to closest mesh points)

        % Metric question: How to represent error in selection?
        %     average distace from selected spot to hard nodule?
        %     average distance from hard nodule to closest selection?

        % Metric question: how do we count that a nodule has been found?
        %     Define some arbitrary epsilon that indicates a nodule has been
        %     "located"

        % Total Experiment time in seconds (convert from nanoseconds)
%         TODO: USE A 'PALPATION ON' VARIABLE TO CALCULATE TIME
        experimentLengthInS = (output.psm_cur.time(end)-output.psm_cur.time(1))/1E9;
        
    end
metrics. experimentLengthInS=experimentLengthInS;