function HOrgan = readTxtReg(filename)
regFile=fopen(filename);
fgetl(regFile);
pos=str2num(fgetl(regFile)); %#ok<*ST2NM>
fgetl(regFile);
quat=str2num(fgetl(regFile)); %XYZW
quat=[quat(4) quat(1:3)];
HOrgan=transformation(quat2rotm(quat),pos); 

end