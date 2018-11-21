% This function averages any number of rotation matrices given as function
% inputs
% Input can be of 2 forms
%   A) a list of rotation matrices averageRotations(R1,R2,R3)
%   B) a 3x3xn matrix of rotation matrices
%   Should also be able to handle multiple matrices...

function R=averageRotations(varargin)
Rmat=[];
for i=1:length(varargin)
    if size(varargin{i},1)~=3 || size(varargin{i},2)~=3
        error('Please enter matrices of the right size')
    end
    Rmat=cat(3,Rmat,varargin{i});        
end

qMat=[];
for i=1:size(Rmat,3)
    qMat=[qMat,rot2quat(Rmat(:,:,i))];
end
R=quat2rot(averageQuaternions(qMat));
end