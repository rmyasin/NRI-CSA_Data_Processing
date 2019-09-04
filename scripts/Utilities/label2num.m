function organNumber=label2num(organLabel)
if isempty(str2num(organLabel))
  organNumber = upper(organLabel)-65;
else
    organNumber = str2num(organLabel);
end

end