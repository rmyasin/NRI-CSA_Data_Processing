clear
close all
clc
% function metrics = processContinuousPalpation(plotOption)
% if nargin<1
%     plotOption=1;
% end


% organ20_2=readRobTxt('R:\Projects\NRI\User_Study\Data\VU\continuous_palpation\organ20_scan2\','1561669116658094882continous_palpation_2019-06-27-15-58-36_0.txt');
% organ20_1=readRobTxt('R:\Projects\NRI\User_Study\Data\VU\continuous_palpation\organ20_scan1', '1561668140163444042continous_palpation_2019-06-27-15-42-20_0.txt');
% organ10_1=readRobTxt('R:\Projects\NRI\User_Study\Data\VU\continuous_palpation\organ10_scan1','1561666037760880947continous_palpation_2019-06-27-15-07-18_0.txt');
% organ10_2=readRobTxt('R:\Projects\NRI\User_Study\Data\VU\continuous_palpation\organ10_scan2','1561667055988892078continous_palpation_2019-06-27-15-24-16_0.txt');
% save('Continuous_Results');
load('Continuous_Results');

regFolder='R:\Projects\NRI\User_Study\Data\VU\user8\Registration_1558713486339525938';

dataFolderBase= 'R:\Projects\NRI\User_Study\Data\VU\continuous_palpation\';

scan10_1=(organ10_1.psm_cur.time(end)-organ10_1.psm_cur.time(1))/1E9;
scan10_2=(organ10_2.psm_cur.time(end)-organ10_2.psm_cur.time(1))/1E9;
scan20_1=(organ20_1.psm_cur.time(end)-organ20_1.psm_cur.time(1))/1E9;
scan20_2=(organ20_2.psm_cur.time(end)-organ20_2.psm_cur.time(1))/1E9;
continuousPalpationTime=mean([scan10_1 scan10_2 scan20_1 scan20_2]); %15 Minutes! And the results still suck!

cpd_dir=getenv('CPDREG');
featureFolder =[ cpd_dir filesep 'userstudy_data' filesep 'PLY'];
organFolder=[cpd_dir filesep 'userstudy_data' filesep 'PointCloudData' filesep 'RegAprToCT'];

for organNumber=[10,20]
    % Read in organ, get ground truth location of organ/spheres
    organLabel=num2str(organNumber);
    
    for scanNumber=1:2
        
        % Read data file
        load([dataFolderBase filesep 'organ' organLabel '_scan' num2str(scanNumber) ...
            filesep 'organ' organLabel '_scan' num2str(scanNumber) '_editedGP']);
        
        figure
        surf( xfit0, yfit0, zfit0, kfit0)
        axis([min(p1(:,1)), max(p1(:,1)), min(p1(:,2)), max(p1(:,2))]);
        hold on
        scatter3(p1(:,1),p1(:,2),p1(:,3),'r.')
        shading interp;
        set(gca,'XDir','reverse')
        set(gca,'YDir','reverse')
        axis equal
%         axis([min(p1(:,1)), max(p1(:,1)), min(p1(:,2)), max(p1(:,2))]);


        % Find the most recent registration
        
        % Get Organ Points
        [organSTL]= getOrganSTL(regFolder,organLabel);
        organSTL.vertices=organSTL.vertices*1000

        % Get Sphere Points
        [spheresInRobot,sphereCentersInRobot,~,~] = getSpherePoints(regFolder,organLabel,featureFolder);
        patch(organSTL,'FaceColor',[0.2,0.8,0.8],'FaceAlpha',0.2,'EdgeAlpha',0.2,'HandleVisibility','off');
        vplot3(spheresInRobot'*1000,'ro','MarkerSize',20)
        % Get selected POI times
        %TODO: Filter stiffness data to get selected points
        savedPoints=[];
        
    end
end
%         
%         
%         
%         
%         
%         selectedOnMesh= findClosestOnMesh(savedPoints,organSTL.vertices,organSTL.faces);
%         
%         %     TODO: need to convert robot selected points to closest on
%         %     organ and then distance to the sphere center
%         
%         %%         DISTANCE METRIC 1:
%         %       Distance from robot pt to sphere on mesh
%         [distances,closestPoints,indices] = minPointDist(spheresInRobot',selectedOnMesh');
%         
%         %%      DISTANCE METRIC 2:
%         %       Distance from robot pt to sphere center, minus minimum sphere
%         %       distance
%         minDistances=rowNorm(spheresInRobot'-sphereCentersInRobot');
%         [centerDistances,closestPoints2,indices2] = minPointDist(sphereCentersInRobot',selectedOnMesh');
%         for kk=1:length(centerDistances)
%             centerDistances(kk)=centerDistances(kk)-minDistances(indices2(kk));
%         end
%         
%         %% FOUND METRIC 1: number of spheres found/not found
%         % reformulate distance *only* for points close to a sphere
%         % Define epsilon
%         SphereEpsilonSurf = 0.01;
%         SphereEpsilonCenter = 0.005;
%         
%         foundIndex=1;
%         foundSphereList=[];
%         foundIndex2=1;
%         foundSphereList2=[];
%         % Search for closest point to each sphere
%         spheresFound=zeros(size(spheresInRobot,2),1);
%         spheresFoundCenter=zeros(size(spheresInRobot,2),1);
%         closeDistances=zeros(size(spheresInRobot,2),1);
%         closeDistancesCenter=zeros(size(spheresInRobot,2),1);
%         for sphereIndex=1:size(spheresInRobot,2)
%             distanceToSphere=distances(indices==sphereIndex);
%             selectedPoints=selectedOnMesh(:,indices==sphereIndex);
%             
%             if ~isempty(distanceToSphere)
%                 if min(distanceToSphere)<SphereEpsilonSurf
%                     spheresFound(sphereIndex)=1;
%                     [closeDistances(sphereIndex),in]=min(distanceToSphere);
%                     
%                     foundSphereList(:,foundIndex) = selectedPoints(:,in);
%                     foundIndex=foundIndex+1;
%                 end
%             end
%             
%             distanceToCenter=centerDistances(indices2==sphereIndex);
%             selectedPoints2=selectedOnMesh(:,indices2==sphereIndex);
%             if ~isempty(distanceToCenter)
%                 if min(distanceToCenter)<SphereEpsilonCenter
%                     spheresFoundCenter(sphereIndex)=1;
%                     [closeDistancesCenter(sphereIndex),in2]=min(distanceToCenter);
%                     
%                     foundSphereList2(:,foundIndex2) = selectedPoints2(:,in2);
%                     foundIndex2=foundIndex2+1;
%                 end
%             end
%         end
%         
%         closeDistances = closeDistances(logical(spheresFound));
%         closeDistancesCenter = closeDistancesCenter(logical(spheresFoundCenter));
%         
%         %% FOUND METRIC 2: number of extra points not near a sphere
%         totalSpheresPicked = size(selectedOnMesh,2);
%         NsphereFound = length(find(closeDistances));
%         NsphereFoundCenter = length(find(closeDistancesCenter));
%         NpointsNotClosest = totalSpheresPicked-NsphereFound;
%         NpointsCenterNotClosest = totalSpheresPicked-NsphereFoundCenter;
%         
%         clear h
%         if plotOption
%             % Plot results
%             figure
%             %         vplot3(spheresInRobot','b*','MarkerSize',10,'DisplayName','True Location');
%             
%             vplot3(sphereCentersInRobot','k*','MarkerSize',10,'DisplayName','True Center');
%             hold on
%             vplot3(selectedOnMesh','ro','MarkerSize',10,'DisplayName','Selected');
%             %         vplot3(foundSphereList','yo','MarkerSize',10,'DisplayName','Found');
%             vplot3(foundSphereList2','yo','MarkerSize',10,'DisplayName','Found');
%             
%             %         vplot3(spheresInRobot','bo','MarkerSize',10,'HandleVisibility','off');
%             vplot3(sphereCentersInRobot','ko','MarkerSize',10,'HandleVisibility','off');
%             
%             vplot3(selectedOnMesh','r*','MarkerSize',10,'HandleVisibility','off');
%             %         vplot3(foundSphereList','y*','MarkerSize',10,'HandleVisibility','off');
%             vplot3(foundSphereList2','y*','MarkerSize',10,'HandleVisibility','off');
%             patch(organSTL,'FaceColor',[0.2,0.8,0.8],'FaceAlpha',0.2,'EdgeAlpha',0.2,'HandleVisibility','off');
%             view([187,89]);
%             legend()
%             %         if ~isempty(foundSphereList)
%             %             legend(h,'True Location','True Location Center','Far Selected Point','Close Selected Point');
%             %         else
%             %             legend(h,'True Location','True Location Center','Far Selected Point');
%             %         end
%             vplot3(cur.pos/1000,'DisplayName','Motion History')
%             axis equal
%         end
%         
%         %% Completion Time Metric
% %         TODO - GET THIS WORKING FROM BAGGED DATA
%         
%         %     if isempty(endTimeIndex)
%         %         fullTime=(output.buttons.coag.time(end)-output.buttons.coag.time(1))/1E9;
%         %     else
%         %         startTimes=output.allow_points.time(startTimeIndex);
%         %         endTimes=output.allow_points.time(endTimeIndex);
%         %         fullTime = sum(endTimes-startTimes)/1E9;
%         %     end
%         %% Collect Metrics
%         %     experimentLengthInS(jj) = fullTime;%(output.psm_cur.time(end)-output.psm_cur.time(1))/1E9; %#ok<*AGROW>
%         
%         distanceList{jj}=distances;
%         centerDistanceList{jj}=centerDistances;
%         NsphereFoundList(jj) = NsphereFound;
%         NsphereFoundCenterList(jj) = NsphereFoundCenter;
%         totalSphereList(jj) = totalSpheresPicked;
%         NExtraPoints(jj) = NpointsNotClosest;
%         NExtraPointsCenter(jj) = NpointsCenterNotClosest;
%         closeDist{jj} = closeDistances;
%         closeDistCenter{jj} = closeDistancesCenter;
%     end
% end
% 
% % metrics.completionTime=experimentLengthInS;
% metrics.distanceList=distanceList;
% metrics.centerDistances=centerDistanceList;
% 
% metrics.spheresFound=NsphereFoundList;
% metrics.spheresFoundCenter=NsphereFoundCenterList;
% metrics.spheresTotal=totalSphereList;
% metrics.extraSelect = NExtraPoints;
% metrics.extraSelectCenter = NExtraPointsCenter;
% 
% metrics.closeDist = closeDist;
% metrics.closeDistCenter = closeDistCenter;

% end