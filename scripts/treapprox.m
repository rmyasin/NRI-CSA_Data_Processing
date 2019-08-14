% Inputs:
% X: 3XN matrix of fiducial locations
% T: 3xN matrix of task target points to calculate expected TRE at
% RMS_FLE: expected fidicial localization error

function [TRE_RMS,F1,F2,F3] = treapprox(X,T,RMS_FLE)
[K,N] = size(X);
meanX = mean(X')';
Xc = X-meanX*ones(1,N);  % demeaned X
[V, Lambda, U] = svd(Xc);
[K,M_T] = size(T);
Tc = T-meanX;  % T relative to centroid of X
Tv = V'*Tc;   % T referred to principal axes of X
 
% Distances of target to the markers' three principal axes:
D1 = Tv(2,:).^2 + Tv(3,:).^2;
D2 = Tv(3,:).^2 + Tv(1,:).^2;
D3 = Tv(1,:).^2 + Tv(2,:).^2;
% RMS distances of markers to their three principal axes:
F1 = (Lambda(2,2)^2 + Lambda(3,3)^2)/N;
F2 = (Lambda(3,3)^2 + Lambda(1,1)^2)/N;
F3 = (Lambda(1,1)^2 + Lambda(2,2)^2)/N;
% TRE:
TRE_RMS = sqrt((RMS_FLE^2/N)*(1 + (1/3)*(D1/F1 + D2/F2 + D3/F3)));


