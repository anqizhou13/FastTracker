clear all
close all
clc

%% MODULE 2 - Kinematics data processing
addpath library

% Initialize the path where the file is contained
group = 'HS';
subject = 'HS01';
trialname = 'Sain_2020_10_30_BAn_GBMOV_T1_OFF_GNG_GAIT_001';
elaboration.trialname = trialname;

pathfile = ['..\\_icm_data\rawdata\',group,'\',subject,'\',trialname,'\raw'];
pathsave = ['..\\_icm_data\rawdata\',group,'\',subject,'\',trialname,'\emg'];
mkdir(pathsave)

load([pathfile,'\_emgRaw.mat'])