function [organSTL,HOrgan]= getOrganSTL(regFolder,organLabel)
cpd_dir=getenv('CPDREG');
filename=[cpd_dir filesep '\userstudy_data\PointCloudData\OutputMesh\Kidney_' num2str(organLabel) '_UserStudy.stl'];
[faces,vertices]=stlread(filename);

registrationFilePath = [regFolder filesep 'PSM2Phantom' num2str(label2num(organLabel)) '.txt'];
HOrgan=readTxtReg(registrationFilePath);

organHomog=[vertices';ones(1,size(vertices,1))];
organReg=HOrgan*organHomog;
organSTL.vertices=organReg(1:3,:)';
organSTL.faces=faces;

end




