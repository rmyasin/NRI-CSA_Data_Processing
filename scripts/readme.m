% This folder contains processing scripts for the NRI-CSA user study
% Rashid Yasin Fall, 2019

%% Data Pipeline:
% During the experiments, bags are saved in ROS that record all the raw
% signals. These are read using a python script and relevant signals are
% saved to .txt files (MATLAB is too slow to open these very large bags).
% After the .txt files have been saved, mat files are saved of each
% experiment's data. These mat files are used to extract the relevant
% metrics for the user study's characterization of user performance. 

%% Python file: main_process_experient.py
% Extracts relevant information from a .bag file and saves it as a .txt
% file

%% User study files 
% Main_Get_Experiment_Metrics - this is the most important script that
% takes the .txt files and extracts the data, processes the metrics, and
% plots them (using subfunctions)

% Main_Save_Figures - second-most important file - saves the figures used
% for the publication

%Subfiles:
% getExperimentFiles - get the file locations of one user's experiments
% SaveExperimentData - save data to a .mat file for a user's experiments
% processArteryExperiment - convert raw data to performance metrics,
    % for ablation experiment, plotting optional
% processPalpationExperiment - convert raw data to performance metrics
    % for palpation experiment, plotting optional
% plotArteryStatistics - plot boxplots of overall ablation metrics
% plotPalpationStatistics - plot boxplots of overall palpation metrics