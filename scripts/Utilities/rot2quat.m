%% rot2quat: Rotation matrix to quaternion
% This function converts a rotation matrix R into a normalized quaternion
% q. Taken from Siciliano's textbook
%#codegen
function q=rot2quat(R)
    eta=sqrt(R(1,1)+R(2,2)+R(3,3)+1)/2;
    if sign(R(3,2)-R(2,3))>=0
        s1=1;
    else
        s1=-1;
    end
    if sign(R(1,3)-R(3,1))>=0
        s2=1;
    else
        s2=-1;
    end
    if sign(R(2,1)-R(1,2))>=0
        s3=1;
    else
        s3=-1;
    end
    n=0.5*[s1*sqrt(abs(R(1,1)-R(2,2)-R(3,3)+1));
           s2*sqrt(abs(R(2,2)-R(1,1)-R(3,3)+1));
           s3*sqrt(abs(R(3,3)-R(2,2)-R(1,1)+1))];
    q=[eta;n];
    q = q/norm(q);
end