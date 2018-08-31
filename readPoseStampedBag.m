function structOut=readPoseStampedBag(topicList)
if iscell(topicList)
    structOut.time=[];
    poses=[];
    for ii=1:length(topicList)
        structOut.time=[structOut.time;topicList{ii}.MessageList.Time];
        poses=[poses;topicList{ii}.readMessages];
    end
else    
    structOut.time=topicList.MessageList.Time;
    poses=topicList.readMessages;
end

poseList=[poses{:}];

myP=[poseList.Pose];
pos=[myP.Position];
x=[pos.X];
y=[pos.Y];
z=[pos.Z];
or=[myP.Orientation];
qx=[or.X];
qy=[or.Y];
qz=[or.Z];
qw=[or.W];

structOut.x=x;
structOut.y=y;
structOut.z=z;
structOut.qx=qx;
structOut.qy=qy;
structOut.qz=qz;
structOut.qw=qw;


Q=[qw;qx;qy;qz]';
structOut.R=quat2rotm(Q);

end
