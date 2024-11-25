clear all
close all
clc

%% MODULE 1 - Motion capture data extraction and visualization

addpath library

% Initialize the path where the file is contained
group = 'HS';
subject = 'HS01';
filename = 'Sain_2020_10_30_BAn_GBMOV_T1_OFF_GNG_GAIT_001.c3d';

pathfile = ['..\\_icm_data\rawdata\',group,'\',subject,'\',filename];
pathsave = ['..\\_icm_data\rawdata\',group,'\',subject,'\',filename(1:end-4),'\raw'];
mkdir(pathsave)


% Labels of interest - markers
markers_labels = {'C7';'RSHO';'LSHO';'RELB';'RWRA';'RWRB';'LELB';'LWRA';'LWRB';...
    'RASI';'LASI';'RPSI';'LPSI';...
    'RCONDE';'RCONDI';'RPER';'RTTA';'RMALE';'RMALI';'RHEE';'RMETA5';'RMETA1';'RHLX';...
    'LCONDE';'LCONDI';'LPER';'LTTA';'LMALE';'LMALI';'LHEE';'LMETA5';'LMETA1';'LHLX';};


h = btkReadAcquisition(pathfile);       % Read the .c3d file
events = btkGetEvents(h);               % Extract the gait events
fs_markers = btkGetPointFrequency(h);   % Extract markers sampling frequency


%%%%%%%%%%%%%%%%%% Marker trajectories %%%%%%%%%%%%%%%%%%

markers_temp = btkGetMarkers(h);             % Extract marker trajectories
for i = 1:length(markers_labels)             % Keeps only the markers of interest
    markers.(markers_labels{i}) = markers_temp.(markers_labels{i});
end

%%% Heel and toe markers vertical trajectories and gait events %%%

figure('Units','centimeters','position',[20 3 15 10])

% Right side
subplot(211)
plot(markers.RHEE(:,3),'k')
hold on 
plot(markers.RHLX(:,3),'k:')
xline(events.Right_Foot_Strike*fs_markers,'g')
xline(events.Right_Foot_Off*fs_markers,'g--')
title('Right heel and toe trajectories, gait events')
xlim([0 inf]); xlabel('Frames'); ylabel('[mm]')

% Left side
subplot(212)
plot(markers.LHEE(:,3),'k')
hold on 
plot(markers.LHLX(:,3),'k:')
xline(events.Left_Foot_Strike*fs_markers,'r')
xline(events.Left_Foot_Off*fs_markers,'r--')
title('Left heel and toe trajectories, gait events')
xlim([0 inf]); xlabel('Frames'); ylabel('[mm]')
legend('Heel', 'Toe')

% Saving the figure
saveas(gca,[pathsave,'\trajec_gaitEvents.fig'])


%%% Marker's trajectory visualization of the last right gait event %%%
figure('Units','centimeters','position',[4 4 16 24])
% Extract the markers and store them in a matrix form, with columns 1, 4,
% 7, .. contains the trajectories on the x axis, columns 2, 5, 8, .. y,
% columns 3, 6 , 9, .. z
markerValues = [];
for i = 1:length(markers_labels)
    markerValues = [markerValues, btkGetPoint(h, markers_labels{i})];
end

event1 = round(events.Right_Foot_Strike(end-1)*fs_markers);
event2 = round(events.Right_Foot_Strike(end)*fs_markers);
timevec = event1:event2;

subplot(311)
plot(markerValues(timevec,1:3:size(markerValues,2)))
title('Mediolateral direction (x)')
xlabel('Frames'); ylabel('[mm]')
xlim([0 inf]); grid on

subplot(312)
plot(markerValues(timevec,2:3:size(markerValues,2)))
title('Anteriorposterior direction (y)')
xlabel('Frames'); ylabel('[mm]')
xlim([0 inf]); grid on

subplot(313)
plot(markerValues(timevec,3:3:size(markerValues,2)))
title('Vertical direction (z)')
xlabel('Frames'); ylabel('[mm]')
xlim([0 inf]); grid on

% Saving the figure
saveas(gca,[pathsave,'\trajec_allMarkers.fig'])


%%%%%%%%%%%%%%%%%% Surface Electromyography %%%%%%%%%%%%%%%%%%

analogs = btkGetAnalogs(h);                 % Extract all the analogs
labels = fieldnames(analogs);               % Extract the associated labels
fs_analogs = btkGetAnalogFrequency(h);      % Extract the analog sampling frequency

emg_labels = labels(end-5:end);             % Select only the analogs containing sEMG signals 

for i = 1:length(emg_labels)
    emgs(:,i) = analogs.(emg_labels{i});
end

% sEMG visualization of the last right gait event 
figure('Units','centimeters','position',[26 12 22 16])

event1_emg = round(events.Right_Foot_Strike(end-1)*fs_analogs);
event2_emg = round(events.Right_Foot_Strike(end)*fs_analogs);
timevec_emg = event1_emg:event2_emg;

for i = 1:size(emgs,2)
    subplot(3,2,i)
    plot(emgs(timevec_emg,i))
    title(emg_labels{i}(9:end))
    xlabel('Sample'); ylabel('[mV]')
    xlim([0 inf]); grid on
end

% Saving the figure
saveas(gca,[pathsave,'\emg_raws.fig'])

% Saving the markers data
save([pathsave,'\_markers.mat'],"events","fs_markers","markers","markers_labels")
% Saving the emg data
save([pathsave,'\_emgRaw.mat'],"events","fs_analogs","emgs","emg_labels")