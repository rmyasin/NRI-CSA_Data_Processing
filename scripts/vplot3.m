function vplot3(inputMat,colorstring)
if size(inputMat,2)~=3
    error('Must input an NX3 matrix');
end

if nargin<2
    colorstring='';
end

plot3(inputMat(:,1),inputMat(:,2),inputMat(:,3),colorstring)
end