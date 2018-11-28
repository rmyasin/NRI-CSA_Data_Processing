%% Function Average Quaternions
% Jason Pile
% 1/15/2013

% This method of finding an average quaternion based on a set of given
% quaternions is based on the paper "Averaging Quaternions" by Yang Cheng,
% Landis Markley, John Crassidis, and Yaakov Oshman.

% This function implements the unweighted version of the averaging method

% Inputs:
% Q: [4 x n] set of n quaternions arranged in collumn vectors
% nonRobotFormat: unless this value is 1, function assumes quaternions are
% defined as [q0, qx, qy, qz].  If the input is 1 then the format is [qx,
% qy, qz, q0]

% Outputs:
% q_avg: [4x1] average quaternion, always in format [q0, qx, qy, qz]

function q_avg=averageQuaternions(Q,nonRobotFormat)
if nargin<2
    nonRobotFormat=0;
end
    n=size(Q,2); % number of quaternions to be averaged
    M=zeros(4,4);
    assert(size(Q,1)==4,'Error in quaternion format');
    
    for i=1:n
        if nonRobotFormat==1
            q=Q(i,:); % create 1x4 quaternion
        else
            q=[Q(2:4,i);Q(1,i)]; % create 1x4 quaternion
        end
        M=M+q*q';
    end
    
    [V D]=eig(M);
    [val, index]=max(diag(D));
    q_avg=[V(4,index);V(1:3,index)];
    
end