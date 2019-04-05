function [expOrgan,expName,regTimes,regNames]=getExperimentFiles(dataFolder)
contents=dir(dataFolder);
regTimes=[];
regNames={};
expOrgan{5}={};
expName{5}={};
expOrgan{6}={};
expName{6}={};

for ii=1:length(contents)
    key = contents(ii).name;
    if startsWith(key,'Registration')
        regNames{end+1}=contents(ii).name;
        regTimes(end+1)=str2num(contents(ii).name(14:end));
    elseif startsWith(key,'Following_Visual') && endsWith(key,'.txt')
        start = length('Following_Visual')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{1}= key(start:finish);
        expName{1}=contents(ii).name;
    elseif startsWith(key,'Following_BarVision') && endsWith(key,'.txt')
        start = length('Following_BarVision')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{2}= key(start:finish);
        expName{2}=contents(ii).name;
    elseif startsWith(key,'Following_DirectForce') && endsWith(key,'.txt')
        start = length('Following_DirectForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{3}= key(start:finish);
        expName{3}=contents(ii).name;
    elseif startsWith(key,'Following_HybridForce') && endsWith(key,'.txt')
        start = length('Following_HybridForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{4}= key(start:finish);
        expName{4}=contents(ii).name;
    elseif startsWith(key,'Palpation_DirectForce') && endsWith(key,'.txt')
        start = length('Palpation_DirectForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{5}= {expOrgan{5}{:},key(start:finish)};
        expName{5}={expName{5}{:},contents(ii).name};
    elseif startsWith(key,'Palpation_VisualForce') && endsWith(key,'.txt')
        start = length('Palpation_VisualForce')+2;
        a=strfind(key(start:end),'_');
        finish = start+a(1)-2;
        expOrgan{6}= {expOrgan{6}{:},key(start:finish)};
        expName{6}={expName{6}{:},contents(ii).name};
    end
end

end