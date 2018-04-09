function [tempfeats,tempfeatlabels] = extractfeats_mat(IMU_DAQ,GONIO_DAQ,EMG_DAQ,RorL,EventInds,WinLen,WinInc,MaxDelay)
% Function: Perform feature extraction for all modalities

% Input: Processed signals, right (1) or left leg (2) index (to determine which is ipsi/contra), event indices, and feature extraction window
% criterion
% Output: tempfeats matrix (instances x features) and tempfeatlabels cell
% array (names of channels/features)

% Function dependencies:
% getIMUfeats.m
% getGONIOfeats.m
% getEMGfeats.m

%%%%%
% Documented by: Blair Hu 08/04/17
%%%%%

% Create variables to store feature matrices and feature labels
tempIMUfeats = [];
tempIMUfeatlabels = [];
tempGONIOfeats = [];
tempGONIOfeatlabels = [];
tempEMGfeats = [];
tempEMGfeatlabels = [];
tempfeats = [];
tempfeatlabels = [];

if RorL == 1 % Right
    % Do nothing because the right side (ipsilateral) channels are already defined first
elseif RorL == 2 % Left
    % Flip the order so that the left side (ipsilateral) channels are
    % defined first
    IMU_temp = IMU_DAQ;
    GONIO_temp = GONIO_DAQ;
    EMG_temp = EMG_DAQ;
    IMU_DAQ = [IMU_temp(:,13:24) IMU_temp(:,1:12) IMU_temp(:,25:30)];
    GONIO_DAQ = [GONIO_temp(:,3:4) GONIO_temp(:,1:2)];
    EMG_DAQ = [EMG_temp(:,8:14) EMG_temp(:,1:7)];
end

F_s = 1000; % Hard-coded sampling frequency (1 kHz)
% Use numerical differentiation (centered-difference) to approximate the joint velocities
GONIO_VEL = numderiv(GONIO_DAQ,F_s,0);

% Specify which channels correspond to which modalities
IMU_chan_select = 1:30;
GONIO_chan_select = 31:38;
EMG_chan_select = 39:52;

% Concatenate all channels
temp = [IMU_DAQ GONIO_DAQ GONIO_VEL EMG_DAQ];

% Specify which features to use with getGONIOfeats, getIMUfeats,
% getEMGfeats
IMU_feat_select = 1:6; % Mean, std, min, max, initial, final
GONIO_feat_select = 1:6; % Mean, std, min, max, initial, final
EMG_feat_select = 1:10; % MAV, SSC, ZC, WL, AR coefficients

% Specify the start of the feature extraction windows (relative to the gait
% event)
Win_Start = -WinLen:WinInc:(-WinLen+MaxDelay);

tempfeats = cell(1,length(Win_Start));

% Iterate over gait events
for i = 1:length(EventInds)
    % Iterate over delayed windows
    for j = 1:length(Win_Start)
        [tempIMUfeats,tempIMUfeatlabels] = getIMUfeats(temp((EventInds(i)+Win_Start(j)):(EventInds(i)+Win_Start(j)+WinLen-1),IMU_chan_select),IMU_chan_select,IMU_feat_select);
        [tempGONIOfeats,tempGONIOfeatlabels] = getGONIOfeats(temp((EventInds(i)+Win_Start(j)):(EventInds(i)+Win_Start(j)+WinLen-1),GONIO_chan_select),GONIO_chan_select-30,GONIO_feat_select);
        [tempEMGfeats,tempEMGfeatlabels] = getEMGfeats(temp((EventInds(i)+Win_Start(j)):(EventInds(i)+Win_Start(j)+WinLen-1),EMG_chan_select),EMG_chan_select-38,EMG_feat_select);
        
        tempfeats{1,j} = [tempfeats{1,j}; [tempIMUfeats tempGONIOfeats tempEMGfeats]];
    end
end

tempfeatlabels = [tempIMUfeatlabels; tempGONIOfeatlabels; tempEMGfeatlabels];
end