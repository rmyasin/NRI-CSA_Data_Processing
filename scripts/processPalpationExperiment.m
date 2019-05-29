function metrics = processPalpationExperiment(dataFolder,ii,expOrgan,regTimes,regNames,plotOption)
cpd_dir=getenv('CPDREG');
featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];
organFolder=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];

    for jj=1:length(expOrgan{ii})
        % Read in organ, get ground truth location of organ/spheres
        organLabel=expOrgan{ii}{jj};
        
        % Read data file
        load([dataFolder filesep 'matlab' filesep 'Output' num2str(ii) '_' num2str(jj)],'output');
        cur=output.psm_cur;
        micronTip=output.micronTip;

        % Find the most recent registration
        registrationIndex=find((cur.time(1)-regTimes)>0,1,'last');
        regFolder=regNames{registrationIndex};

        % Get Organ Points
        [organSTL,H2]= getOrganSTL([dataFolder filesep regFolder],organLabel);

        % Get Sphere Points
        [spheresInRobot,sphereCentersInRobot,~,~] = getSpherePoints([dataFolder filesep regFolder],organLabel,featureFolder);

        % Get selected POI times
        if isempty(output.display_points.time)
            savedPoints=[];
            selectedOnMesh=[];
            warning(['No Points Saved!\n' dataFolder '\nOrgan is ' organLabel]);
        else
            savedPoints=output.display_points.data{end};
            selectedOnMesh= findClosestOnMesh(savedPoints,organSTL.vertices,organSTL.faces);
        end


        if plotOption
            % Plot results
            figure
            vplot3(spheresInRobot','b*','MarkerSize',10)
            hold on
            vplot3(sphereCentersInRobot','k*','MarkerSize',10)
            vplot3(selectedOnMesh','ro','MarkerSize',10)
            
            
            vplot3(spheresInRobot','bo','MarkerSize',10)
            
            vplot3(sphereCentersInRobot','ko','MarkerSize',10)
            
            vplot3(selectedOnMesh','r*','MarkerSize',10)
            vplot3(savedPoints','r.','MarkerSize',10)
            vplot3(savedPoints','r.','MarkerSize',10)
            patch(organSTL,'FaceColor',[0.2,0.8,0.8],'FaceAlpha',0.2,'EdgeAlpha',0.2)
            view([187,89])
            legend('True Location','True Location Center','Selected Point');
            axis equal
        end
        registrationFilePath = [dataFolder filesep regFolder filesep 'Micron2Phantom' num2str(label2num(organLabel)) '.txt'];
        HMicron=readTxtReg(registrationFilePath);
        
        if isempty(micronTip.pos)
            warning('No Micron Data!')
        else
            micronHomog=H2*(HMicron\[micronTip.pos';ones(1,length(micronTip.pos))]);
        end
        
        %     TODO: need to convert robot selected points to closest on
        %     organ and then distance to the sphere center
        
%%         DISTANCE METRIC 1:
%       Distance from robot pt to sphere on mesh
        [distances,closestPoints,indices] = minPointDist(spheresInRobot',selectedOnMesh');
        
%%      DISTANCE METRIC 2:
%       Distance from robot pt to sphere center, minus minimum sphere
%       distance
      minDistances=rowNorm(spheresInRobot'-sphereCentersInRobot');
      [centerDistances,closestPoints2,indices2] = minPointDist(sphereCentersInRobot',selectedOnMesh');
      for kk=1:length(centerDistances)
          centerDistances(kk)=centerDistances(kk)-minDistances(indices2(kk));
      end
      if any(indices~=indices2)
          warning('Something funny going on in closest point calculation')
      end

    %% FOUND METRIC 1: number of spheres found/not found
    % reformulate distance *only* for points close to a sphere
    % Define epsilon
    SphereEpsilonSurf = 0.01;
    SphereEpsilonCenter = 0.01;
      
    % Search for closest point to each sphere
    spheresFound=zeros(size(spheresInRobot,2),1);
    spheresFoundCenter=zeros(size(spheresInRobot,2),1);
    closeDistances=zeros(size(spheresInRobot,2),1);
    closeDistancesCenter=zeros(size(spheresInRobot,2),1);
    for sphereIndex=1:size(spheresInRobot,2)
        distanceToSphere=distances(indices==sphereIndex);
        if ~isempty(distanceToSphere)
            if min(distanceToSphere)<SphereEpsilonSurf
                spheresFound(sphereIndex)=1;
                closeDistances(sphereIndex)=min(distanceToSphere);
            end
        end
        
        distanceToCenter=centerDistances(indices2==sphereIndex);
        if ~isempty(distanceToCenter)
            if min(distanceToCenter)<SphereEpsilonCenter
                spheresFoundCenter(sphereIndex)=1;
                closeDistancesCenter(sphereIndex)=min(distanceToCenter);
            end
        end
    end
    
    closeDistances = closeDistances(logical(spheresFound));
    closeDistancesCenter = closeDistancesCenter(logical(spheresFoundCenter));
    
    %% FOUND METRIC 2: number of extra points not near a sphere
    totalSpheresPicked = size(selectedOnMesh,2);
    NsphereFound = length(find(closeDistances));
    NsphereFoundCenter = length(find(closeDistancesCenter));
    NpointsNotClosest = totalSpheresPicked-NsphereFound;
    NpointsCenterNotClosest = totalSpheresPicked-NsphereFoundCenter;
        
    %% Completion Time Metric 
    startTimeIndex=find(output.allow_points.data);
    endTimeIndex=find(output.allow_points.data==0);
    startTimes=output.allow_points.time(startTimeIndex);
    endTimes=output.allow_points.time(endTimeIndex);
    fullTime = sum(endTimes-startTimes)/1E9;
    
    %% Collect Metrics    
    experimentLengthInS(jj) = fullTime;%(output.psm_cur.time(end)-output.psm_cur.time(1))/1E9; %#ok<*AGROW>
    distanceList{jj}=distances;
    centerDistanceList{jj}=centerDistances;
    NsphereFoundList(jj) = NsphereFound;
    NsphereFoundCenterList(jj) = NsphereFoundCenter;
    totalSphereList(jj) = totalSpheresPicked;
    NExtraPoints(jj) = NpointsNotClosest;
    NExtraPointsCenter(jj) = NpointsCenterNotClosest;
    closeDist{jj} = closeDistances;
    closeDistCenter{jj} = closeDistancesCenter;
    end

metrics.completionTime=experimentLengthInS;
metrics.distanceList=distanceList;
metrics.centerDistances=centerDistanceList;

metrics.spheresFound=NsphereFoundList;
metrics.spheresFoundCenter=NsphereFoundCenterList;
metrics.spheresTotal=totalSphereList;
metrics.extraSelect = NExtraPoints;
metrics.extraSelectCenter = NExtraPointsCenter;

metrics.closeDist = closeDist;
metrics.closeDistCenter = closeDistCenter;

end