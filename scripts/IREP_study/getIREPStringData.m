function stringData=getIREPStringData(dataFolder,userList,saveData)

for ii=1:length(userList)
    userNumber=userList(ii);
    fullFolder=[dataFolder filesep 'user' num2str(userNumber)];
    contents=dir(fullFolder);
    contentsCell={contents.name};
    indices=startsWith(contentsCell,'String_') & endsWith(contentsCell,'.txt');
    experimentNames=contentsCell(indices);

    if saveData
        for jj=1:length(experimentNames)
            [output]=readRobTxt(fullFolder,experimentNames{jj});
            save([fullFolder filesep experimentNames{jj}(1:end-4) '_processed'],'output');
            stringData{ii,jj}=output;
            stringData{ii,jj}.pathType=str2double(experimentNames{jj}(strfind(experimentNames{jj},'String_')+7));
        end
    else
    content=dir(fullFolder);
    nameList={content.name};
    folderList={content.folder};
    index = startsWith({content.name},'String_') & endsWith({content.name},'processed.mat');
    folders=folderList(index);
    names=nameList(index);
    for jj=1:length(names)
        load([strcat(folders{jj},filesep,names{jj})]);
        stringData{ii,jj}=output;
        stringData{ii,jj}.pullType =str2double(names{jj}(strfind(names{jj},'String_')+7));
    end
    end
end