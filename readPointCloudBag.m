function structOut=readPointCloudBag(topicList)
structOut.time=topicList.MessageList.Time;

points=topicList.readMessages;
pcList=[points{:}];

myP=[pcList.Points];
x=[myP.X];
y=[myP.Y];
z=[myP.Z];

structOut.x=x;
structOut.y=y;
structOut.z=z;

end
