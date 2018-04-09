function getfeatsfromsegmented
% Function: take resegmented files (in the form of
% CircuitXXX_resegmented.mat), perform feature extraction, and save new
% files for classification

% Input: None (to be selected using GUI)
% Output: ABXXX_feats_reprocessed.mat, Raw/Processed CSV for each trial,
% checkEMG/checkGONIO metadata, all_LW_EMG/all_LW_GONIO for representative
% data for LW

% Function dependencies:
% uipickfiles.m
% extractfeats_mat.m 

%%%%%
% Documented by: Blair Hu 03/23/18
%%%%%

% Open up the file selection GUI
files = uipickfiles;

% Specify the window length, window increment, and latest relative window
% time (relative to the gait event)
WinLen = 300;
WinInc = 30;
MaxDelay = 120;
numtimepts = length(-WinLen:WinInc:(-WinLen+MaxDelay));

% Prepare output variables
feats = cell(1,numtimepts);
legphase = [];
trig = {};
subject = {};
fnames = {};

R_stance_fnames = {};
R_stance_gonio = {};
R_stance_emg = {};

R_swing_fnames = {};
R_swing_gonio = {};
R_swing_emg = {};

L_stance_fnames = {};
L_stance_gonio = {};
L_stance_emg = {};

L_swing_fnames = {};
L_swing_gonio = {};
L_swing_emg = {};

for i = 1:length(files)
    load(files{i});
    [fpath,fname,fext] = fileparts(files{i});
    cd(fpath);
    disp([fpath,'\',fname]);
    
    subjID_ind = findstr('AB',fpath);
    subjID = fpath(subjID_ind:(subjID_ind+4));
    
    circuitID_ind = findstr('Circuit',fname);
    circuitID = fname(circuitID_ind:(circuitID_ind+10));
    
    fnames = [fnames; [subjID,'_',circuitID]];
    
    raw = load([fpath(1:end-15),'Raw\',subjID,'\',circuitID,'.mat']);
    eval(['EMG_RAW = raw.',circuitID,'.daq.DAQ_DATA(:,[31:37 39:43 45:46]);']);
    eval(['IMU_RAW = raw.',circuitID,'.daq.DAQ_DATA(:,[1:30]);']);
    eval(['GONIO_RAW = raw.',circuitID,'.daq.DAQ_DATA(:,[47:50]);']);
    
    IMU_DAQ_CHAN_LP = output_struct{14};
    
    EMG_DAQ_CHAN_HP = output_struct{15};
    EMG_DAQ_CHAN_HPLP = LPfilt(1000,6,350,EMG_DAQ_CHAN_HP);
    EMG_DAQ_CHAN_FILT = NOTCHfilt(1000,6,[57 177 297],[63 183 303],EMG_DAQ_CHAN_HPLP);     
    
    % Replace EMG processing with wider bandstop filter (applied to raw
    % data after HP and LP)
    EMG_HP = HPfilt(1000,6,20,EMG_RAW);
    EMG_LP = LPfilt(1000,6,350,EMG_HP);
    EMG_ALLFILT = NOTCHfilt(1000,6,[57 177 297],[63 183 303],EMG_LP);
    
    GONIO_DAQ_CHAN_LP = output_struct{16};
    
    if strcmp(subjID,'AB192') % Reverse sign for knee position only for this subject (and flip right and left channels)
        GONIO_RAW(:,5) = GONIO_RAW(:,3);
        GONIO_RAW(:,6) = -GONIO_RAW(:,4);
        GONIO_RAW(:,7) = GONIO_RAW(:,1);
        GONIO_RAW(:,8) = -GONIO_RAW(:,2);
        GONIO_RAW = GONIO_RAW(:,5:8);
        
        GONIO_DAQ_CHAN_LP_FINAL(:,1) = GONIO_DAQ_CHAN_LP(:,3);
        GONIO_DAQ_CHAN_LP_FINAL(:,2) = -GONIO_DAQ_CHAN_LP(:,4);
        GONIO_DAQ_CHAN_LP_FINAL(:,3) = GONIO_DAQ_CHAN_LP(:,1);
        GONIO_DAQ_CHAN_LP_FINAL(:,4) = -GONIO_DAQ_CHAN_LP(:,2);
    else
        GONIO_DAQ_CHAN_LP_FINAL = GONIO_DAQ_CHAN_LP;
    end
    % Get numerical derivative of goniometer channels to save with processed data
    GONIO_VEL = numderiv(GONIO_DAQ_CHAN_LP_FINAL,1000,0);
    
    MODE = output_struct{17};
    
    R_IC = output_struct{2};
    R_IC_trig = output_struct{3};
    R_EC = output_struct{4};
    R_EC_trig = output_struct{5};
    L_IC = output_struct{8};
    L_IC_trig = output_struct{9};
    L_EC = output_struct{10};
    L_EC_trig = output_struct{11};
    
%     EMG_RMS = [];
%     
%     % Check EMG quality by comparing signal to noise at baseline (during
%     % rest when the subject is not moving as determined by the IMU)
%     if length(R_IC) + length(R_EC) + length(L_IC) + length(L_EC) > 0
%         AVEL_THRESH = 5;
%         AVEL_STILL = find(IMU_DAQ_CHAN_LP(:,4) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,5) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,6) < AVEL_THRESH & ...
%             IMU_DAQ_CHAN_LP(:,10) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,11) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,12) < AVEL_THRESH & ...
%             IMU_DAQ_CHAN_LP(:,16) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,17) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,18) < AVEL_THRESH & ...
%             IMU_DAQ_CHAN_LP(:,22) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,23) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,24) < AVEL_THRESH & ...
%             IMU_DAQ_CHAN_LP(:,28) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,29) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,30) < AVEL_THRESH);
%         for j = 1:size(EMG_ALLFILT,2)
%             EMG_RMS(:,j) = RMSfilter(EMG_ALLFILT(:,j),200,199,1);
%             BASELINE_MEAN = mean(EMG_RMS(AVEL_STILL,j));
%             EMG_SNR(i,j) = 20*log10(max(EMG_RMS(:,j))/BASELINE_MEAN);
%         end
%     
%         start_walk = min([R_IC; R_EC; L_IC; L_EC]);
%         stop_walk = max([R_IC; R_EC; L_IC; L_EC]);
%         for j = 1:size(GONIO_DAQ_CHAN_LP_FINAL,2)
%             GONIO_MEAN(i,j) = mean(GONIO_DAQ_CHAN_LP_FINAL(start_walk:stop_walk,j));
%             GONIO_SD(i,j) = std(GONIO_DAQ_CHAN_LP_FINAL(start_walk:stop_walk,j));
%             GONIO_MIN(i,j) = min(GONIO_DAQ_CHAN_LP_FINAL(start_walk:stop_walk,j));
%             GONIO_MAX(i,j) = max(GONIO_DAQ_CHAN_LP_FINAL(start_walk:stop_walk,j));
%         end
% 
%         for ric = 1:length(R_IC_trig)-1
%             if strcmp(R_IC_trig(ric),'1311')
%                 nextTO = min(find(R_EC > R_IC(ric)));
%                 if length(nextTO) > 0 && strcmp(R_EC_trig(nextTO),'1112') && (R_EC(nextTO) - R_IC(ric) < 1500)
%                     R_stance_fnames = [R_stance_fnames; [subjID,'_',circuitID]];
%                     R_stance_gonio = [R_stance_gonio; GONIO_DAQ_CHAN_LP_FINAL(R_IC(ric):R_EC(nextTO),1:2)];
%                     R_stance_emg = [R_stance_emg; EMG_RMS(R_IC(ric):R_EC(nextTO),1:7)];
%                 end
%             end
%         end
%         for lic = 1:length(L_IC_trig)-1
%             if strcmp(L_IC_trig(lic),'1311')
%                 nextTO = min(find(L_EC > L_IC(lic)));
%                 if length(nextTO) > 0 && strcmp(L_EC_trig(nextTO),'1112') && (L_EC(nextTO) - L_IC(lic) < 1500)
%                     L_stance_fnames = [L_stance_fnames; [subjID,'_',circuitID]];
%                     L_stance_gonio = [L_stance_gonio; GONIO_DAQ_CHAN_LP_FINAL(L_IC(lic):L_EC(nextTO),3:4)];
%                     L_stance_emg = [L_stance_emg; EMG_RMS(L_IC(lic):L_EC(nextTO),8:14)];
%                 end
%             end
%         end
%         for rec = 1:length(R_EC_trig)-1
%             if strcmp(R_EC_trig(rec),'1112')
%                 nextHC = min(find(R_IC > R_EC(rec)));
%                 if length(nextHC) > 0 && strcmp(R_IC_trig(nextHC),'1311') && (R_IC(nextHC) - R_EC(rec) < 1500)
%                     R_swing_fnames = [R_swing_fnames; [subjID,'_',circuitID]];
%                     R_swing_gonio = [R_swing_gonio; GONIO_DAQ_CHAN_LP_FINAL(R_EC(rec):R_IC(nextHC),1:2)];
%                     R_swing_emg = [R_swing_emg; EMG_RMS(R_EC(rec):R_IC(nextHC),1:7)];
%                 end
%             end
%         end
%         for lec = 1:length(L_EC_trig)-1
%             if strcmp(L_EC_trig(lec),'1112')
%                 nextHC = min(find(L_IC > L_EC(lec)));
%                 if length(nextHC) > 0 && strcmp(L_IC_trig(nextHC),'1311') && (L_IC(nextHC) - L_EC(lec) < 1500)
%                     L_swing_fnames = [L_swing_fnames; [subjID,'_',circuitID]];
%                     L_swing_gonio = [L_swing_gonio; GONIO_DAQ_CHAN_LP_FINAL(L_EC(lec):L_IC(nextHC),3:4)];
%                     L_swing_emg = [L_swing_emg; EMG_RMS(L_EC(lec):L_IC(nextHC),8:14)];
%                 end
%             end
%         end
%     else
%         disp('Skipping file...');
%     end
    %% Feature extraction
    RorL = 1; % Right foot is ipsilateral
    [R_HC_feats,featlabels] = extractfeats_mat(IMU_DAQ_CHAN_LP,GONIO_DAQ_CHAN_LP_FINAL,EMG_DAQ_CHAN_FILT,RorL,R_IC,WinLen,WinInc,MaxDelay);
    [R_TO_feats,~] = extractfeats_mat(IMU_DAQ_CHAN_LP,GONIO_DAQ_CHAN_LP_FINAL,EMG_DAQ_CHAN_FILT,RorL,R_EC,WinLen,WinInc,MaxDelay);
    RorL = 2; % Left foot is ipsilateral
    [L_HC_feats,~] = extractfeats_mat(IMU_DAQ_CHAN_LP,GONIO_DAQ_CHAN_LP_FINAL,EMG_DAQ_CHAN_FILT,RorL,L_IC,WinLen,WinInc,MaxDelay);
    [L_TO_feats,~] = extractfeats_mat(IMU_DAQ_CHAN_LP,GONIO_DAQ_CHAN_LP_FINAL,EMG_DAQ_CHAN_FILT,RorL,L_EC,WinLen,WinInc,MaxDelay);
    for m = 1:numtimepts % Iterates over number of delayed windows
        feats{1,m} = [feats{1,m}; R_HC_feats{m}];
        feats{1,m} = [feats{1,m}; R_TO_feats{m}];
        feats{1,m} = [feats{1,m}; L_HC_feats{m}];
        feats{1,m} = [feats{1,m}; L_TO_feats{m}];
    end
    %% Save legphase, trigger, and subject ID variables concatenated across all trials
    legphase = [legphase; repmat(1,length(R_IC),1); repmat(2,length(R_EC),1); repmat(3,length(L_IC),1); repmat(4,length(L_EC),1)];
    trig = [trig; R_IC_trig; R_EC_trig; L_IC_trig; L_EC_trig];
    subject = vertcat(subject,repmat(subjID,length(R_IC)+length(R_EC)+length(L_IC)+length(L_EC),1));
        
%     raw_colnames = {'Right_Shank_Ax' 'Right_Shank_Ay' 'Right_Shank_Az' ...
%     'Right_Shank_Gy' 'Right_Shank_Gz' 'Right_Shank_Gx' ...
%     'Right_Thigh_Ax' 'Right_Thigh_Ay' 'Right_Thigh_Az' ...
%     'Right_Thigh_Gy' 'Right_Thigh_Gz' 'Right_Thigh_Gx' ...
%     'Left_Shank_Ax' 'Left_Shank_Ay' 'Left_Shank_Az' ...
%     'Left_Shank_Gy' 'Left_Shank_Gz' 'Left_Shank_Gx' ...
%     'Left_Thigh_Ax' 'Left_Thigh_Ay' 'Left_Thigh_Az' ...
%     'Left_Thigh_Gy' 'Left_Thigh_Gz' 'Left_Thigh_Gx' ...
%     'Waist_Ax' 'Waist_Ay' 'Waist_Az' ...
%     'Waist_Gy' 'Waist_Gz' 'Waist_Gx' ...
%     'Right_TA' 'Right_MG' 'Right_SOL' 'Right_BF' 'Right_ST' 'Right_VL' 'Right_RF' ...
%     'Left_TA' 'Left_MG' 'Left_SOL' 'Left_BF' 'Left_ST' 'Left_VL' 'Left_RF' ...
%     'Right_Ankle' 'Right_Knee' 'Left_Ankle' 'Left_Knee' ...
%     'Mode'};    
%     
%     post_colnames = {'Right_Shank_Ax' 'Right_Shank_Ay' 'Right_Shank_Az' ...
%     'Right_Shank_Gy' 'Right_Shank_Gz' 'Right_Shank_Gx' ...
%     'Right_Thigh_Ax' 'Right_Thigh_Ay' 'Right_Thigh_Az' ...
%     'Right_Thigh_Gy' 'Right_Thigh_Gz' 'Right_Thigh_Gx' ...
%     'Left_Shank_Ax' 'Left_Shank_Ay' 'Left_Shank_Az' ...
%     'Left_Shank_Gy' 'Left_Shank_Gz' 'Left_Shank_Gx' ...
%     'Left_Thigh_Ax' 'Left_Thigh_Ay' 'Left_Thigh_Az' ...
%     'Left_Thigh_Gy' 'Left_Thigh_Gz' 'Left_Thigh_Gx' ...
%     'Waist_Ax' 'Waist_Ay' 'Waist_Az' ...
%     'Waist_Gy' 'Waist_Gz' 'Waist_Gx' ...
%     'Right_TA' 'Right_MG' 'Right_SOL' 'Right_BF' 'Right_ST' 'Right_VL' 'Right_RF' ...
%     'Left_TA' 'Left_MG' 'Left_SOL' 'Left_BF' 'Left_ST' 'Left_VL' 'Left_RF' ...
%     'Right_Ankle' 'Right_Knee' 'Left_Ankle' 'Left_Knee' ...
%     'Right_Ankle_Velocity' 'Right_Knee_Velocity' 'Left_Ankle_Velocity' 'Left_Knee_Velocity' ...
%     'Mode' 'Right_Heel_Contact' 'Right_Heel_Contact_Trigger' ...
%     'Right_Toe_Off' 'Right_Toe_Off_Trigger' 'Left_Heel_Contact' 'Left_Heel_Contact_Trigger' ...
%     'Left_Toe_Off' 'Left_Toe_Off_Trigger'};    
%     
%     CHAN_RAW = [IMU_RAW EMG_RAW GONIO_RAW MODE];
%     T_RAW = array2table(CHAN_RAW,'VariableNames',raw_colnames);
%     writetable(T_RAW,[subjID,'_',circuitID,'_raw.csv'],'Delimiter',',')
% 
%     EVENTS_INFO = nan(length(MODE),8);
%     EVENTS_INFO(1:length(R_IC),1) = R_IC;
%     EVENTS_INFO(1:length(R_IC_trig),2) = str2num(cell2mat(R_IC_trig));
%     EVENTS_INFO(1:length(R_EC),3) = R_EC;
%     EVENTS_INFO(1:length(R_EC_trig),4) = str2num(cell2mat(R_EC_trig));
%     EVENTS_INFO(1:length(L_IC),5) = L_IC;
%     EVENTS_INFO(1:length(L_IC_trig),6) = str2num(cell2mat(L_IC_trig));
%     EVENTS_INFO(1:length(L_EC),7) = L_EC;
%     EVENTS_INFO(1:length(L_EC_trig),8) = str2num(cell2mat(L_EC_trig));
%     
%     CHAN_POST = [IMU_DAQ_CHAN_LP EMG_ALLFILT GONIO_DAQ_CHAN_LP_FINAL GONIO_VEL MODE EVENTS_INFO];
%     T_POST = array2table(CHAN_POST,'VariableNames',post_colnames);
%     writetable(T_POST,[subjID,'_',circuitID,'_post.csv'],'Delimiter',',')
    
    EMG_DAQ_CHAN_FILT = [];
    EMG_ALLFILT = [];
    GONIO_DAQ_CHAN_LP_FINAL = [];
    IMU_DAQ_CHAN_LP = [];
end
% save('checkEMG.mat','fnames','EMG_SNR');
% save('checkGONIO.mat','fnames','GONIO_MEAN','GONIO_SD','GONIO_MIN','GONIO_MAX');
% save('all_LW_EMG.mat','R_stance_fnames','R_stance_emg','L_stance_fnames','L_stance_emg','R_swing_fnames','R_swing_emg','L_swing_fnames','L_swing_emg');
% save('all_LW_GONIO.mat','R_stance_fnames','R_stance_gonio','L_stance_fnames','L_stance_gonio','R_swing_fnames','R_swing_gonio','L_swing_fnames','L_swing_gonio');    

subject = cellstr(cell2mat(subject));
% save(['AllSubs_feats_reprocessed_032818.mat'],'feats','legphase','trig','subject','featlabels');
save([subjID,'_feats_reprocessed_032818TD.mat'],'feats','legphase','trig','subject','featlabels');
end