
function tipTotal=getMicronTip(micron,a)

fullPos=[];
fullRot=[];
fullFrames=[];
fullTip=[];
fullLabel=[];
fullTime=[];

for ii=1:length(a.labelList)
    
    curLabel=a.labelList(ii);
    index=[micron.label]==curLabel;
    
    if find(index)
        for jj=1:size(micron(index).pose,3)
            tip(:,jj)=micron(index).pose(:,:,jj)* [a.tipLoc(:,a.labelList==curLabel);1];
        end        
        switch curLabel
            case 50
                curRot=zeros(3,3,size(micron(index).rot,3));
                for jj=1:size(micron(index).rot,3)
                    curRot(:,:,jj)=averageRotations(...
                    micron(index).rot(:,:,jj)*a.HNextMarker(1:3,1:3,3)*a.HNextMarker(1:3,1:3,4),...
                    micron(index).rot(:,:,jj)*a.HNextMarker(1:3,1:3,2)'*a.HNextMarker(1:3,1:3,1)');
                end
            case 51
                curRot=micron(index).rot;
            case 52 
                curRot=zeros(3,3,size(micron(index).rot,3));
                for jj=1:size(micron(index).rot,3)
                    curRot(:,:,jj)=micron(index).rot(:,:,jj)*a.HNextMarker(1:3,1:3,1)';
                end
            case 53
                curRot=zeros(3,3,size(micron(index).rot,3));
                for jj=1:size(micron(index).rot,3)
                    curRot(:,:,jj)=micron(index).rot(:,:,jj)*a.HNextMarker(1:3,1:3,4);
                end
        end
%         Scalar - nx1
        fullTime=[fullTime; micron(index).time];
        fullFrames=[fullFrames; micron(index).frame];
        fullLabel=[fullLabel;ones(length(micron(index).frame),1)*curLabel];
%        Vector 3xn
        fullPos=cat(2,fullPos, micron(index).pos');
        fullTip=cat(2,fullTip,tip(1:3,:));
%         Matrix mxmxn
        fullRot=cat(3,fullRot,curRot);
    end
end
[tipTotal.time,indexList]=sort(fullTime);
tipTotal.frame=fullFrames(indexList);
tipTotal.label=fullLabel(indexList);
tipTotal.posMarker=fullPos(:,indexList);
tipTotal.tip=fullTip(:,indexList);
tipTotal.rot=fullRot(:,:,indexList);
tmp=cat(2,tipTotal.rot,reshape(tipTotal.tip,3,1,[]));
tipTotal.pose=cat(1,tmp,repmat([0,0,0,1],1,1,size(tmp,3)));