%% quaternion to rotation matrix
% Jason Pile
% function to convert unit quaternion to rotation matrix
function R=quat2rot(q)
%assert(length(q)==4,'Not quaternion')
q = q/norm(q); % renormalized
a=q(1); b=q(2); c=q(3); d=q(4); % intermediate variables for readability
R=[a^2+b^2-c^2-d^2, 2*(b*c-a*d), 2*(b*d+a*c);
    2*(b*c+a*d), a^2-b^2+c^2-d^2, 2*(c*d-a*b);
    2*(b*d-a*c), 2*(c*d+a*b), a^2-b^2-c^2+d^2];
end