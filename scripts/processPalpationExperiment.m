% Takes saved data from SaveExperimentData() and calculates metrics for NRI
% user study of "palpation" to find subsurface features
% % Inputs:
% dataFolder - folder of experiment data
% ii - index of which experiment to process
% expOrgan - label of organ used in this experiment
% regTimes - most recent registration time
% regNames - list of registration files in data folder
% plotOption - whether or not to plot
% userNumber - which user is performing the experiment
% % Outputs:
% metrics - metrics of user performance
    % completionTime - time to complete one palpation experiment
    % distanceList - list of distances from selected features to points
    % centerDistances - list of distances from selected features to centers
    % spheresFound - number of spheres found
    % spheresFoundCenter - number of spheres found using center distance
    % spheresTotal - total number of spheres in this organ
    % extraSelect - excess features 'found' 
    % extraSelectCenter - excess features 'found' using center distance
    % closeDist - distance of found features
    % closeDistCenter - distance of found features using center distance

function metrics = processPalpationExperiment(dataFolder,ii,expOrgan,regTimes,regNames,plotOption,userNumber)
cpd_dir=getenv('CPDREG');
featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];
organFolder=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];

for jj=1:length(expOrgan{ii})
    % Read in organ, get ground truth location of organ/spheres
    organLabel=expOrgan{ii}{jj};
%     disp(['Experiment ' num2str(ii) ' Organ ' num2str(organLabel) ' Iteration ' jj]);
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
    
    
    %% Fix data errors in point selection
    [selectedOnMesh,extraPoints] = reduceSpheres(selectedOnMesh,userNumber,ii,jj);

    %% 
    registrationFilePath = [dataFolder filesep regFolder filesep 'Micron2Phantom' num2str(label2num(organLabel)) '.txt'];
    HMicron=readTxtReg(registrationFilePath);
    
    if isempty(micronTip.pos)
%         warning('No Micron Data!')
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
    
    %% FOUND METRIC 1: number of spheres found/not found
    % reformulate distance *only* for points close to a sphere
    % Define epsilon
    SphereEpsilonSurf = 0.01;
    SphereEpsilonCenter = 0.005;
    
    foundIndex=1;
    foundSphereList=[];
    foundIndex2=1;
    foundSphereList2=[];
    % Search for closest point to each sphere
    spheresFound=zeros(size(spheresInRobot,2),1);
    spheresFoundCenter=zeros(size(spheresInRobot,2),1);
    closeDistances=zeros(size(spheresInRobot,2),1);
    closeDistancesCenter=zeros(size(spheresInRobot,2),1);
    for sphereIndex=1:size(spheresInRobot,2)
        distanceToSphere=distances(indices==sphereIndex);
        selectedPoints=selectedOnMesh(:,indices==sphereIndex);
        
        if ~isempty(distanceToSphere)
            if min(distanceToSphere)<SphereEpsilonSurf
                spheresFound(sphereIndex)=1;
                [closeDistances(sphereIndex),in]=min(distanceToSphere);
                
                foundSphereList(:,foundIndex) = selectedPoints(:,in);
                foundIndex=foundIndex+1;
            end
        end
        
        distanceToCenter=centerDistances(indices2==sphereIndex);
        selectedPoints2=selectedOnMesh(:,indices2==sphereIndex);
        if ~isempty(distanceToCenter)
            if min(distanceToCenter)<SphereEpsilonCenter
                spheresFoundCenter(sphereIndex)=1;
                [closeDistancesCenter(sphereIndex),in2]=min(distanceToCenter);
                
                foundSphereList2(:,foundIndex2) = selectedPoints2(:,in2);
                foundIndex2=foundIndex2+1;
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
    
    clear h
    if plotOption
        % Plot results
        figure
%         vplot3(spheresInRobot','b*','MarkerSize',10,'DisplayName','True Location');
        
        vplot3(sphereCentersInRobot','k*','MarkerSize',10,'DisplayName','True Center');
        hold on
        vplot3(selectedOnMesh','ro','MarkerSize',10,'DisplayName','Selected');
%         vplot3(foundSphereList','yo','MarkerSize',10,'DisplayName','Found');
        vplot3(extraPoints','o','Color',[160,160,160]/255,'MarkerSize',10,'DisplayName','Removed');
        vplot3(foundSphereList2','yo','MarkerSize',10,'DisplayName','Found');
        

%         vplot3(spheresInRobot','bo','MarkerSize',10,'HandleVisibility','off');
        vplot3(sphereCentersInRobot','ko','MarkerSize',10,'HandleVisibility','off');
        
        vplot3(selectedOnMesh','r*','MarkerSize',10,'HandleVisibility','off');
%         vplot3(foundSphereList','y*','MarkerSize',10,'HandleVisibility','off');
        vplot3(extraPoints','*','Color',[160,160,160]/255,'MarkerSize',10,'HandleVisibility','off');        
        vplot3(foundSphereList2','y*','MarkerSize',10,'HandleVisibility','off');
        patch(organSTL,'FaceColor',[0.2,0.8,0.8],'FaceAlpha',0.2,'EdgeAlpha',0.2,'HandleVisibility','off');
        view([187,89]);
        legend()
%         if ~isempty(foundSphereList)
%             legend(h,'True Location','True Location Center','Far Selected Point','Close Selected Point');
%         else
%             legend(h,'True Location','True Location Center','Far Selected Point');
%         end
%         vplot3(cur.pos/1000,'DisplayName','Motion History')
        axis equal
    end
    
    
    %% Completion Time Metric
    startTimeIndex=find(output.allow_points.data);
    endTimeIndex=find(output.allow_points.data==0);
    if isempty(endTimeIndex)
        fullTime=(output.buttons.coag.time(end)-output.buttons.coag.time(1))/1E9;
    else
        startTimes=output.allow_points.time(startTimeIndex);
        endTimes=output.allow_points.time(endTimeIndex);
        fullTime = sum(endTimes-startTimes)/1E9;
    end
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