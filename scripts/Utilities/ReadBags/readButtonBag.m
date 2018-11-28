function structOut=readButtonBag(topicList)
structOut.time=topicList.MessageList.Time;

joys=topicList.readMessages;
joyList=[joys{:}];

structOut.buttonState=[joyList.Buttons];

end
