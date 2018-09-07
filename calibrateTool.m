% Calibrate a tool that has been rotated around some fixed rotation point
% Inputs:
%   xyz: an Nx3 matrix
%   Rinput: a 3x3xN matrix or a 3Nx3 matrix

function [tipLoc,baseLoc,centerPtList]=calibrateTool(xyz,Rinput,transpose)
if nargin<3
    transpose=0;
end
Rtall=[];
for i=1:size(Rinput,3)
    if transpose
        Rtall=[Rtall;Rinput(:,:,i)'];
    else
        Rtall=[Rtall;Rinput(:,:,i)];
    end
end
Imat=repmat(eye(3),size(Rtall,1)/3,1);
point=xyz';
pointList=point(:);
A=[Rtall, -Imat];
t=A\(-pointList);

tipLoc=t(1:3);
baseLoc=t(4:6);

% We can calculate the projection of the points back to the center - the
% spread of these points will tell you if you have a bad calibration or 
% if the tool slipped during the calibration procedure
for i=1:1:size(Rinput,3)
    if transpose
        centerPtList(:,i)=point(:,i)+Rinput(:,:,i)'*tipLoc;
    else
        centerPtList(:,i)=point(:,i)+Rinput(:,:,i)*tipLoc;
    end
end

end