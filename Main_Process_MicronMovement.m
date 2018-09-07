clear
close all
clc

addpath(genpath(getenv('ARMA_CL')))
addpath(genpath(getenv('ECLDIR')))
% armalib_dir=getenv('ARMAlib_DIR');
% rosgenmsg([armalib_dir filesep 'msg'])
rosgenmsg('C:\Dev\test')

% Bag folder
bagFolder='R:\Projects\NRI\User_Study\Data\Bags\path_following\';
% Create bag objects

%%
pathBag=rosbag([bagFolder '1536010631139967918path_following_2018-09-03-16-37-11_0.bag']);

bagOutput=readPathBag(pathBag);
