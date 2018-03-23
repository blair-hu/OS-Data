function exportsegmented
% Function: take resegmented files (in the form of
% CircuitXXX_resegmented.mat) and save to .xls

% Input: None (to be selected using GUI)
% Output: ABXXX_CircuitXXX.xlsx

% Function dependencies:
% uipickfiles.m
% numderiv.m

%%%%%
% Documented by: Blair Hu 08/24/17
%%%%%

close all

% Open up the file selection GUI
files = uipickfiles;
% % % fnames = {};
alldata = {};

colnames = {'Right_Shank_Ax' 'Right_Shank_Ay' 'Right_Shank_Az' ...
    'Right_Shank_Gy' 'Right_Shank_Gz' 'Right_Shank_Gx' ...
    'Right_Thigh_Ax' 'Right_Thigh_Ay' 'Right_Thigh_Az' ...
    'Right_Thigh_Gy' 'Right_Thigh_Gz' 'Right_Thigh_Gx' ...
    'Left_Shank_Ax' 'Left_Shank_Ay' 'Left_Shank_Az' ...
    'Left_Shank_Gy' 'Left_Shank_Gz' 'Left_Shank_Gx' ...
    'Left_Thigh_Ax' 'Left_Thigh_Ay' 'Left_Thigh_Az' ...
    'Left_Thigh_Gy' 'Left_Thigh_Gz' 'Left_Thigh_Gx' ...
    'Waist_Ax' 'Waist_Ay' 'Waist_Az' ...
    'Waist_Gy' 'Waist_Gz' 'Waist_Gx' ...
    'Right_TA' 'Right_MG' 'Right_SOL' 'Right_BF' 'Right_ST' 'Right_VL' 'Right_RF' ...
    'Left_TA' 'Left_MG' 'Left_SOL' 'Left_BF' 'Left_ST' 'Left_VL' 'Left_RF' ...
    'Right_Ankle' 'Right_Knee' 'Left_Ankle' 'Left_Knee' ...
    'Right_Ankle_Velocity' 'Right_Knee_Velocity' 'Left_Ankle_Velocity' 'Left_Knee_Velocity' ...
    'Mode' 'Right_Heel_Contact' 'Right_Heel_Contact_Trigger' ...
    'Right_Toe_Off' 'Right_Toe_Off_Trigger' 'Left_Heel_Contact' 'Left_Heel_Contact_Trigger' ...
    'Left_Toe_Off' 'Left_Toe_Off_Trigger'};

ric_lw_gonio = {};
ric_ra_gonio = {};
ric_rd_gonio = {};
ric_sa_gonio = {};
ric_sd_gonio = {};

lic_lw_gonio = {};
lic_ra_gonio = {};
lic_rd_gonio = {};
lic_sa_gonio = {};
lic_sd_gonio = {};

ric_lw_emg = {};
ric_ra_emg = {};
ric_rd_emg = {};
ric_sa_emg = {};
ric_sd_emg = {};

lic_lw_emg = {};
lic_ra_emg = {};
lic_rd_emg = {};
lic_sa_emg = {};
lic_sd_emg = {};

% R_stance_save = [];
R_stance_fnames = {};
R_stance_gonio = {};
R_stance_emg = {};

% R_swing_save = [];
R_swing_fnames = {};
R_swing_gonio = {};
R_swing_emg = {};

% L_stance_save = [];
L_stance_fnames = {};
L_stance_gonio = {};
L_stance_emg = {};

% L_swing_save = [];
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
    
% % %     fnames = [fnames; [subjID,'_',fname]];
    
    circuitID_ind = findstr('Circuit',fname);
    circuitID = fname(circuitID_ind:(circuitID_ind+10));
    
    raw = load([circuitID,'.mat']);
    eval(['EMG_RAW = raw.',circuitID,'.daq.DAQ_DATA(:,[31:37 39:43 45:46]);']);
    eval(['IMU_RAW = raw.',circuitID,'.daq.DAQ_DATA(:,[1:30]);']);
    eval(['GONIO_RAW = raw.',circuitID,'.daq.DAQ_DATA(:,[47:50]);']);
    
    IMU_DAQ_CHAN_LP = output_struct{14};
    %     EMG_DAQ_CHAN_HP_LP_NOTCH = output_struct{15};
    
    % Re-do EMG processing
    EMG_HP = HPfilt(1000,6,20,EMG_RAW);
    EMG_LP = LPfilt(1000,6,350,EMG_HP);
    EMG_ALLFILT = NOTCHfilt(1000,6,[57 177 297],[63 183 303],EMG_LP);
    GONIO_DAQ_CHAN_LP = output_struct{16};
    
    % Subtract out the mean
    %     for goniocol = 1:4
    %         if goniocol == 1 || goniocol == 3
    %             GONIO_DAQ_CHAN_LP_HP(:,goniocol) = GONIO_DAQ_CHAN_LP(:,goniocol) - mean(GONIO_DAQ_CHAN_LP(:,goniocol));
    %         else
    %             GONIO_DAQ_CHAN_LP_HP(:,goniocol) = GONIO_DAQ_CHAN_LP(:,goniocol);
    %         end
    %     end
    
    if strcmp(subjID,'AB192') % Reverse sign for knee position only for this subject (and flip right and left channels)
        GONIO_RAW(:,5) = GONIO_RAW(:,3);
        GONIO_RAW(:,6) = -GONIO_RAW(:,4);
        GONIO_RAW(:,7) = GONIO_RAW(:,1);
        GONIO_RAW(:,8) = -GONIO_RAW(:,2);
        GONIO_RAW = GONIO_RAW(:,5:8);
        
        GONIO_DAQ_CHAN_LP_HP(:,1) = GONIO_DAQ_CHAN_LP(:,3);
        GONIO_DAQ_CHAN_LP_HP(:,2) = -GONIO_DAQ_CHAN_LP(:,4);
        GONIO_DAQ_CHAN_LP_HP(:,3) = GONIO_DAQ_CHAN_LP(:,1);
        GONIO_DAQ_CHAN_LP_HP(:,4) = -GONIO_DAQ_CHAN_LP(:,2);
    else
        GONIO_DAQ_CHAN_LP_HP = GONIO_DAQ_CHAN_LP;
    end
    GONIO_VEL = numderiv(GONIO_DAQ_CHAN_LP_HP,1000,0);
    MODE = output_struct{17};
    
    R_IC = output_struct{2};
    R_IC_trig = output_struct{3};
    R_EC = output_struct{4};
    R_EC_trig = output_struct{5};
    L_IC = output_struct{8};
    L_IC_trig = output_struct{9};
    L_EC = output_struct{10};
    L_EC_trig = output_struct{11};
    
    % Check EMG quality by comparing signal to noise at baseline (during
    % rest when the subject is not moving as determined by the IMU)
    if length(R_IC) + length(R_EC) + length(L_IC) + length(L_EC) > 0
        AVEL_THRESH = 5;
        AVEL_STILL = find(IMU_DAQ_CHAN_LP(:,4) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,5) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,6) < AVEL_THRESH & ...
            IMU_DAQ_CHAN_LP(:,10) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,11) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,12) < AVEL_THRESH & ...
            IMU_DAQ_CHAN_LP(:,16) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,17) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,18) < AVEL_THRESH & ...
            IMU_DAQ_CHAN_LP(:,22) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,23) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,24) < AVEL_THRESH & ...
            IMU_DAQ_CHAN_LP(:,28) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,29) < AVEL_THRESH & IMU_DAQ_CHAN_LP(:,30) < AVEL_THRESH);
        
        %     SIT_A = [output_struct{18}(1); output_struct{18}(end)];
        %     STAND_A = [output_struct{19}(1); output_struct{19}(end)];
        %     STAND_B = [output_struct{20}(1); output_struct{20}(end)];
        %     SIT_B = [output_struct{21}(1); output_struct{21}(end)];
        
        for j = 1:size(EMG_ALLFILT,2)
            EMG_RMS(:,j) = RMSfilter(EMG_ALLFILT(:,j),200,199,1);
            BASELINE_MEAN = mean(EMG_RMS(AVEL_STILL,j));
            EMG_SNR(i,j) = 20*log10(max(EMG_RMS(:,j))/BASELINE_MEAN);
        end
        
        start_walk = min([R_IC; R_EC; L_IC; L_EC]);
        stop_walk = max([R_IC; R_EC; L_IC; L_EC]);
        
        for j = 1:size(GONIO_DAQ_CHAN_LP_HP,2)
            GONIO_MEAN(i,j) = mean(GONIO_DAQ_CHAN_LP_HP(start_walk:stop_walk,j));
            GONIO_SD(i,j) = std(GONIO_DAQ_CHAN_LP_HP(start_walk:stop_walk,j));
            GONIO_MIN(i,j) = min(GONIO_DAQ_CHAN_LP_HP(start_walk:stop_walk,j));
            GONIO_MAX(i,j) = max(GONIO_DAQ_CHAN_LP_HP(start_walk:stop_walk,j));
        end
        
% % %         datatemp = cell(length(MODE)+1,61);
% % %         datatemp(1,:) = colnames;
% % %         datatemp(2:length(MODE)+1,1:52) = num2cell([IMU_DAQ_CHAN_LP EMG_ALLFILT GONIO_DAQ_CHAN_LP_HP GONIO_VEL]);
% % %         datatemp(2:length(MODE)+1,53) = num2cell(MODE);
% % %         datatemp(2:length(R_IC)+1,54) = num2cell(R_IC);
% % %         datatemp(2:length(R_IC_trig)+1,55) = num2cell(str2num(cell2mat(R_IC_trig)));
% % %         datatemp(2:length(R_EC)+1,56) = num2cell(R_EC);
% % %         datatemp(2:length(R_EC_trig)+1,57) = num2cell(str2num(cell2mat(R_EC_trig)));
% % %         datatemp(2:length(L_IC)+1,58) = num2cell(L_IC);
% % %         datatemp(2:length(L_IC_trig)+1,59) = num2cell(str2num(cell2mat(L_IC_trig)));
% % %         datatemp(2:length(L_EC)+1,60) = num2cell(L_EC);
% % %         datatemp(2:length(L_EC_trig)+1,61) = num2cell(str2num(cell2mat(L_EC_trig)));
% % %         
% % %         rawtemp = cell(length(MODE)+1,49);
% % %         rawtemp(1,:) = colnames([1:48 53]);
% % %         rawtemp(2:length(MODE)+1,1:48) = num2cell([IMU_RAW EMG_RAW GONIO_RAW]);
% % %         rawtemp(2:length(MODE)+1,49) = num2cell(MODE);
        
        %     datatemp(2:length(SIT_A)+1,62) = num2cell(SIT_A);
        %     datatemp(2:length(STAND_A)+1,63) = num2cell(STAND_A);
        %     datatemp(2:length(SIT_B)+1,64) = num2cell(SIT_B);
        %     datatemp(2:length(STAND_B)+1,65) = num2cell(STAND_B);
        
        %         xlswrite([fpath,'\XLS\',subjID,'_',circuitID,'_raw'],rawtemp,1);
        %         xlswrite([fpath,'\XLS\',subjID,'_',circuitID,'_post'],datatemp,1);
        
        for ric = 1:length(R_IC_trig)-1
            if strcmp(R_IC_trig(ric),'1311')
                nextTO = min(find(R_EC > R_IC(ric)));
                if length(nextTO) > 0 && strcmp(R_EC_trig(nextTO),'1112') && (R_EC(nextTO) - R_IC(ric) < 1500)
%                     R_stance_save = [R_stance_save; [R_IC(ric) R_EC(nextTO)]];
                    R_stance_fnames = [R_stance_fnames; [subjID,'_',fname]];
                    R_stance_gonio = [R_stance_gonio; GONIO_DAQ_CHAN_LP_HP(R_IC(ric):R_EC(nextTO),1:2)];
                    R_stance_emg = [R_stance_emg; EMG_RMS(R_IC(ric):R_EC(nextTO),1:7)];
                end
            end
        end
        
        for lic = 1:length(L_IC_trig)-1
            if strcmp(L_IC_trig(lic),'1311')
                nextTO = min(find(L_EC > L_IC(lic)));
                if length(nextTO) > 0 && strcmp(L_EC_trig(nextTO),'1112') && (L_EC(nextTO) - L_IC(lic) < 1500)
%                     L_stance_save = [L_stance_save; [L_IC(lic) L_EC(nextTO)]];
                    L_stance_fnames = [L_stance_fnames; [subjID,'_',fname]];
                    L_stance_gonio = [L_stance_gonio; GONIO_DAQ_CHAN_LP_HP(L_IC(lic):L_EC(nextTO),3:4)];
                    L_stance_emg = [L_stance_emg; EMG_RMS(L_IC(lic):L_EC(nextTO),8:14)];
                end
            end
        end
        
        for rec = 1:length(R_EC_trig)-1
            if strcmp(R_EC_trig(rec),'1112')
                nextHC = min(find(R_IC > R_EC(rec)));
                if length(nextHC) > 0 && strcmp(R_IC_trig(nextHC),'1311') && (R_IC(nextHC) - R_EC(rec) < 1500)
%                     R_swing_save = [R_swing_save; [R_EC(rec) R_IC(nextHC)]];
                    R_swing_fnames = [R_swing_fnames; [subjID,'_',fname]];
                    R_swing_gonio = [R_swing_gonio; GONIO_DAQ_CHAN_LP_HP(R_EC(rec):R_IC(nextHC),1:2)];
                    R_swing_emg = [R_swing_emg; EMG_RMS(R_EC(rec):R_IC(nextHC),1:7)];
                end
            end
        end
        
        for lec = 1:length(L_EC_trig)-1
            if strcmp(L_EC_trig(lec),'1112')
                nextHC = min(find(L_IC > L_EC(lec)));
                if length(nextHC) > 0 && strcmp(L_IC_trig(nextHC),'1311') && (L_IC(nextHC) - L_EC(lec) < 1500)
%                     L_swing_save = [L_swing_save; [L_EC(lec) L_IC(nextHC)]];
                    L_swing_fnames = [L_swing_fnames; [subjID,'_',fname]];
                    L_swing_gonio = [L_swing_gonio; GONIO_DAQ_CHAN_LP_HP(L_EC(lec):L_IC(nextHC),3:4)];
                    L_swing_emg = [L_swing_emg; EMG_RMS(L_EC(lec):L_IC(nextHC),8:14)];
                end
            end
        end
        
        for ric = 1:length(R_IC_trig)-1
            if strcmp(R_IC_trig(ric),'1311') && strcmp(R_IC_trig(ric+1),'1311')
                ric_lw_gonio = [ric_lw_gonio; GONIO_DAQ_CHAN_LP_HP(R_IC(ric):R_IC(ric+1),1:2)];
                ric_lw_emg = [ric_lw_emg; EMG_RMS(R_IC(ric):R_IC(ric+1),1:7)];
% % %             elseif strcmp(R_IC_trig(ric),'2321') && strcmp(R_IC_trig(ric+1),'2321')
% % %                 ric_ra_gonio = [ric_ra_gonio; GONIO_DAQ_CHAN_LP_HP(R_IC(ric):R_IC(ric+1),1:2)];
% % %                 ric_ra_emg = [ric_ra_emg; EMG_RMS(R_IC(ric):R_IC(ric+1),1:7)];
% % %             elseif strcmp(R_IC_trig(ric),'3331') && strcmp(R_IC_trig(ric+1),'3331')
% % %                 ric_rd_gonio = [ric_rd_gonio; GONIO_DAQ_CHAN_LP_HP(R_IC(ric):R_IC(ric+1),1:2)];
% % %                 ric_rd_emg = [ric_rd_emg; EMG_RMS(R_IC(ric):R_IC(ric+1),1:7)];
% % %             elseif strcmp(R_IC_trig(ric),'1341') && strcmp(R_IC_trig(ric+1),'4341')
% % %                 ric_sa_gonio = [ric_sa_gonio; GONIO_DAQ_CHAN_LP_HP(R_IC(ric):R_IC(ric+1),1:2)];
% % %                 ric_sa_emg = [ric_sa_emg; EMG_RMS(R_IC(ric):R_IC(ric+1),1:7)];
% % %             elseif strcmp(R_IC_trig(ric),'1351') && strcmp(R_IC_trig(ric+1),'5351')
% % %                 ric_sd_gonio = [ric_sd_gonio; GONIO_DAQ_CHAN_LP_HP(R_IC(ric):R_IC(ric+1),1:2)];
% % %                 ric_sd_emg = [ric_sd_emg; EMG_RMS(R_IC(ric):R_IC(ric+1),1:7)];
            end
        end
        
        for lic = 1:length(L_IC_trig)-1
            if strcmp(L_IC_trig(lic),'1311') && strcmp(L_IC_trig(lic+1),'1311')
                lic_lw_gonio = [lic_lw_gonio; GONIO_DAQ_CHAN_LP_HP(L_IC(lic):L_IC(lic+1),3:4)];
                lic_lw_emg = [lic_lw_emg; EMG_RMS(L_IC(lic):L_IC(lic+1),8:14)];
% % %             elseif strcmp(L_IC_trig(lic),'2321') && strcmp(L_IC_trig(lic+1),'2321')
% % %                 lic_ra_gonio = [lic_ra_gonio; GONIO_DAQ_CHAN_LP_HP(L_IC(lic):L_IC(lic+1),3:4)];
% % %                 lic_ra_emg = [lic_ra_emg; EMG_RMS(L_IC(lic):L_IC(lic+1),8:14)];
% % %             elseif strcmp(L_IC_trig(lic),'3331') && strcmp(L_IC_trig(lic+1),'3331')
% % %                 lic_rd_gonio = [lic_rd_gonio; GONIO_DAQ_CHAN_LP_HP(L_IC(lic):L_IC(lic+1),3:4)];
% % %                 lic_rd_emg = [lic_rd_emg; EMG_RMS(L_IC(lic):L_IC(lic+1),8:14)];
% % %             elseif strcmp(L_IC_trig(lic),'1341') && strcmp(L_IC_trig(lic+1),'4341')
% % %                 lic_sa_gonio = [lic_sa_gonio; GONIO_DAQ_CHAN_LP_HP(L_IC(lic):L_IC(lic+1),3:4)];
% % %                 lic_sa_emg = [lic_sa_emg; EMG_RMS(L_IC(lic):L_IC(lic+1),8:14)];
% % %             elseif strcmp(L_IC_trig(lic),'1351') && strcmp(L_IC_trig(lic+1),'5351')
% % %                 lic_sd_gonio = [lic_sd_gonio; GONIO_DAQ_CHAN_LP_HP(L_IC(lic):L_IC(lic+1),3:4)];
% % %                 lic_sd_emg = [lic_sd_emg; EMG_RMS(L_IC(lic):L_IC(lic+1),8:14)];
            end
        end
        clear rawtemp;
        clear datatemp;
        EMG_RMS = [];
        GONIO_DAQ_CHAN_LP_HP = [];
    else
        disp('Skipping this file');
    end
end

% % % ric_lw_knee = [];
% % % ric_lw_ankle = [];
% % % lic_lw_knee = [];
% % % lic_lw_ankle = [];
% % % figure(1)
% % % for k = 1:length(ric_lw_gonio)
% % %     subplot(221) % LW-Knee
% % %     plot(-interp1(1:length(ric_lw_gonio{k}),ric_lw_gonio{k}(:,2),1:1000));
% % %     ric_lw_knee = [ric_lw_knee -interp1(1:length(ric_lw_gonio{k}),ric_lw_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(223) % LW-Ankle
% % %     plot(-interp1(1:length(ric_lw_gonio{k}),ric_lw_gonio{k}(:,1),1:1000));
% % %     ric_lw_ankle = [ric_lw_ankle -interp1(1:length(ric_lw_gonio{k}),ric_lw_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % for k = 1:length(lic_lw_gonio)
% % %     subplot(222) % LW-Knee
% % %     plot(-interp1(1:length(lic_lw_gonio{k}),lic_lw_gonio{k}(:,2),1:1000));
% % %     lic_lw_knee = [lic_lw_knee -interp1(1:length(lic_lw_gonio{k}),lic_lw_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(224) % LW-Ankle
% % %     plot(-interp1(1:length(lic_lw_gonio{k}),lic_lw_gonio{k}(:,1),1:1000));
% % %     lic_lw_ankle = [lic_lw_ankle -interp1(1:length(lic_lw_gonio{k}),lic_lw_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % subplot(221); title('LW-R-Knee'); plot(1:1000,nanmean(ric_lw_knee,2),'LineWidth',2,'Color','k');
% % % subplot(222); title('LW-L-Knee'); plot(1:1000,nanmean(lic_lw_knee,2),'LineWidth',2,'Color','k');
% % % subplot(223); title('LW-R-Ankle'); plot(1:1000,nanmean(ric_lw_ankle,2),'LineWidth',2,'Color','k');
% % % subplot(224); title('LW-L-Ankle'); plot(1:1000,nanmean(lic_lw_ankle,2),'LineWidth',2,'Color','k');
% % % 
% % % ric_ra_knee = [];
% % % ric_ra_ankle = [];
% % % lic_ra_knee = [];
% % % lic_ra_ankle = [];
% % % figure(2)
% % % for k = 1:length(ric_ra_gonio)
% % %     subplot(221) % RA-Knee
% % %     plot(-interp1(1:length(ric_ra_gonio{k}),ric_ra_gonio{k}(:,2),1:1000));
% % %     ric_ra_knee = [ric_ra_knee -interp1(1:length(ric_ra_gonio{k}),ric_ra_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(223) % RA-Ankle
% % %     plot(-interp1(1:length(ric_ra_gonio{k}),ric_ra_gonio{k}(:,1),1:1000));
% % %     ric_ra_ankle = [ric_ra_ankle -interp1(1:length(ric_ra_gonio{k}),ric_ra_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % for k = 1:length(lic_ra_gonio)
% % %     subplot(222) % RA-Knee
% % %     plot(-interp1(1:length(lic_ra_gonio{k}),lic_ra_gonio{k}(:,2),1:1000));
% % %     lic_ra_knee = [lic_ra_knee -interp1(1:length(lic_ra_gonio{k}),lic_ra_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(224) % RA-Ankle
% % %     plot(-interp1(1:length(lic_ra_gonio{k}),lic_ra_gonio{k}(:,1),1:1000));
% % %     lic_ra_ankle = [lic_ra_ankle -interp1(1:length(lic_ra_gonio{k}),lic_ra_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % subplot(221); title('RA-R-Knee'); plot(1:1000,nanmean(ric_ra_knee,2),'LineWidth',2,'Color','k');
% % % subplot(222); title('RA-L-Knee'); plot(1:1000,nanmean(lic_ra_knee,2),'LineWidth',2,'Color','k');
% % % subplot(223); title('RA-R-Ankle'); plot(1:1000,nanmean(ric_ra_ankle,2),'LineWidth',2,'Color','k');
% % % subplot(224); title('RA-L-Ankle'); plot(1:1000,nanmean(lic_ra_ankle,2),'LineWidth',2,'Color','k');
% % % 
% % % ric_rd_knee = [];
% % % ric_rd_ankle = [];
% % % lic_rd_knee = [];
% % % lic_rd_ankle = [];
% % % figure(3)
% % % for k = 1:length(ric_rd_gonio)
% % %     subplot(221) % RD-Knee
% % %     plot(-interp1(1:length(ric_rd_gonio{k}),ric_rd_gonio{k}(:,2),1:1000));
% % %     ric_rd_knee = [ric_rd_knee -interp1(1:length(ric_rd_gonio{k}),ric_rd_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(223) % RD-Ankle
% % %     plot(-interp1(1:length(ric_rd_gonio{k}),ric_rd_gonio{k}(:,1),1:1000));
% % %     ric_rd_ankle = [ric_rd_ankle -interp1(1:length(ric_rd_gonio{k}),ric_rd_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % for k = 1:length(lic_rd_gonio)
% % %     subplot(222) % RD-Knee
% % %     plot(-interp1(1:length(lic_rd_gonio{k}),lic_rd_gonio{k}(:,2),1:1000));
% % %     lic_rd_knee = [lic_rd_knee -interp1(1:length(lic_rd_gonio{k}),lic_rd_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(224) % RD-Ankle
% % %     plot(-interp1(1:length(lic_rd_gonio{k}),lic_rd_gonio{k}(:,1),1:1000));
% % %     lic_rd_ankle = [lic_rd_ankle -interp1(1:length(lic_rd_gonio{k}),lic_rd_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % subplot(221); title('RD-R-Knee'); plot(1:1000,nanmean(ric_rd_knee,2),'LineWidth',2,'Color','k');
% % % subplot(222); title('RD-L-Knee'); plot(1:1000,nanmean(lic_rd_knee,2),'LineWidth',2,'Color','k');
% % % subplot(223); title('RD-R-Ankle'); plot(1:1000,nanmean(ric_rd_ankle,2),'LineWidth',2,'Color','k');
% % % subplot(224); title('RD-L-Ankle'); plot(1:1000,nanmean(lic_rd_ankle,2),'LineWidth',2,'Color','k');
% % % 
% % % ric_sa_knee = [];
% % % ric_sa_ankle = [];
% % % lic_sa_knee = [];
% % % lic_sa_ankle = [];
% % % figure(4)
% % % for k = 1:length(ric_sa_gonio)
% % %     subplot(221) % SA-Knee
% % %     plot(-interp1(1:length(ric_sa_gonio{k}),ric_sa_gonio{k}(:,2),1:1000));
% % %     ric_sa_knee = [ric_sa_knee -interp1(1:length(ric_sa_gonio{k}),ric_sa_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(223) % SA-Ankle
% % %     plot(-interp1(1:length(ric_sa_gonio{k}),ric_sa_gonio{k}(:,1),1:1000));
% % %     ric_sa_ankle = [ric_sa_ankle -interp1(1:length(ric_sa_gonio{k}),ric_sa_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % for k = 1:length(lic_sa_gonio)
% % %     subplot(222) % SA-Knee
% % %     plot(-interp1(1:length(lic_sa_gonio{k}),lic_sa_gonio{k}(:,2),1:1000));
% % %     lic_sa_knee = [lic_sa_knee -interp1(1:length(lic_sa_gonio{k}),lic_sa_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(224) % SA-Ankle
% % %     plot(-interp1(1:length(lic_sa_gonio{k}),lic_sa_gonio{k}(:,1),1:1000));
% % %     lic_sa_ankle = [lic_sa_ankle -interp1(1:length(lic_sa_gonio{k}),lic_sa_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % subplot(221); title('SA-R-Knee'); % plot(1:1000,nanmean(ric_sa_knee,2),'LineWidth',2,'Color','k');
% % % subplot(222); title('SA-L-Knee'); % plot(1:1000,nanmean(lic_sa_knee,2),'LineWidth',2,'Color','k');
% % % subplot(223); title('SA-R-Ankle'); % plot(1:1000,nanmean(ric_sa_ankle,2),'LineWidth',2,'Color','k');
% % % subplot(224); title('SA-L-Ankle'); % plot(1:1000,nanmean(lic_sa_ankle,2),'LineWidth',2,'Color','k');
% % % 
% % % ric_sd_knee = [];
% % % ric_sd_ankle = [];
% % % lic_sd_knee = [];
% % % lic_sd_ankle = [];
% % % figure(5)
% % % for k = 1:length(ric_sd_gonio)
% % %     subplot(221) % RD-Knee
% % %     plot(-interp1(1:length(ric_sd_gonio{k}),ric_sd_gonio{k}(:,2),1:1000));
% % %     ric_sd_knee = [ric_sd_knee -interp1(1:length(ric_sd_gonio{k}),ric_sd_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(223) % RD-Ankle
% % %     plot(-interp1(1:length(ric_sd_gonio{k}),ric_sd_gonio{k}(:,1),1:1000));
% % %     ric_sd_ankle = [ric_sd_ankle -interp1(1:length(ric_sd_gonio{k}),ric_sd_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % for k = 1:length(lic_sd_gonio)
% % %     subplot(222) % RD-Knee
% % %     plot(-interp1(1:length(lic_sd_gonio{k}),lic_sd_gonio{k}(:,2),1:1000));
% % %     lic_sd_knee = [lic_sd_knee -interp1(1:length(lic_sd_gonio{k}),lic_sd_gonio{k}(:,2),1:1000)'];
% % %     hold on;
% % %     subplot(224) % RD-Ankle
% % %     plot(-interp1(1:length(lic_sd_gonio{k}),lic_sd_gonio{k}(:,1),1:1000));
% % %     lic_sd_ankle = [lic_sd_ankle -interp1(1:length(lic_sd_gonio{k}),lic_sd_gonio{k}(:,1),1:1000)'];
% % %     hold on;
% % % end
% % % subplot(221); title('SD-R-Knee'); plot(1:1000,nanmean(ric_sd_knee,2),'LineWidth',2,'Color','k');
% % % subplot(222); title('SD-L-Knee'); plot(1:1000,nanmean(lic_sd_knee,2),'LineWidth',2,'Color','k');
% % % subplot(223); title('SD-R-Ankle'); plot(1:1000,nanmean(ric_sd_ankle,2),'LineWidth',2,'Color','k');
% % % subplot(224); title('SD-L-Ankle'); plot(1:1000,nanmean(lic_sd_ankle,2),'LineWidth',2,'Color','k');
% % % 
% % % figure(6)
% % % plot(1:1000,nanmean([ric_lw_knee lic_lw_knee],2),'k','LineWidth',2)
% % % hold on;
% % % plot(1:1000,nanmean([ric_lw_knee lic_lw_knee],2) + nanstd([ric_lw_knee lic_lw_knee],0,2),'k--')
% % % plot(1:1000,nanmean([ric_lw_knee lic_lw_knee],2) - nanstd([ric_lw_knee lic_lw_knee],0,2),'k--')
% % % plot(1:1000,nanmean([ric_ra_knee lic_ra_knee],2),'r','LineWidth',2)
% % % plot(1:1000,nanmean([ric_ra_knee lic_ra_knee],2) + nanstd([ric_ra_knee lic_ra_knee],0,2),'r--')
% % % plot(1:1000,nanmean([ric_ra_knee lic_ra_knee],2) - nanstd([ric_ra_knee lic_ra_knee],0,2),'r--')
% % % plot(1:1000,nanmean([ric_rd_knee lic_rd_knee],2),'g','LineWidth',2)
% % % plot(1:1000,nanmean([ric_rd_knee lic_rd_knee],2) + nanstd([ric_rd_knee lic_rd_knee],0,2),'g--')
% % % plot(1:1000,nanmean([ric_rd_knee lic_rd_knee],2) - nanstd([ric_rd_knee lic_rd_knee],0,2),'g--')
% % % plot(1:1000,nanmean([ric_sa_knee lic_sa_knee],2),'c','LineWidth',2)
% % % plot(1:1000,nanmean([ric_sa_knee lic_sa_knee],2) + nanstd([ric_sa_knee lic_sa_knee],0,2),'c--')
% % % plot(1:1000,nanmean([ric_sa_knee lic_sa_knee],2) - nanstd([ric_sa_knee lic_sa_knee],0,2),'c--')
% % % plot(1:1000,nanmean([ric_sd_knee lic_sd_knee],2),'m','LineWidth',2)
% % % plot(1:1000,nanmean([ric_sd_knee lic_sd_knee],2) + nanstd([ric_sd_knee lic_sd_knee],0,2),'m--')
% % % plot(1:1000,nanmean([ric_sd_knee lic_sd_knee],2) - nanstd([ric_sd_knee lic_sd_knee],0,2),'m--')

save('Z:\Lab Member Folders\Blair Hu\Open Source Dataset 2017\ENABL3S\checkEMG.mat','fnames','EMG_SNR');
save('Z:\Lab Member Folders\Blair Hu\Open Source Dataset 2017\ENABL3S\checkGONIO.mat','fnames','GONIO_MEAN','GONIO_SD','GONIO_MIN','GONIO_MAX');
% save('Z:\Lab Member Folders\Blair Hu\Open Source Dataset 2017\ENABL3S\all_SS_EMG.mat','fnames','ric_lw_emg','ric_ra_emg','ric_rd_emg','ric_sa_emg','ric_sd_emg','lic_lw_emg','lic_ra_emg','lic_rd_emg','lic_sa_emg','lic_sd_emg');
% save('Z:\Lab Member Folders\Blair Hu\Open Source Dataset 2017\ENABL3S\all_SS_GONIO.mat','fnames','ric_lw_gonio','ric_ra_gonio','ric_rd_gonio','ric_sa_gonio','ric_sd_gonio','lic_lw_gonio','lic_ra_gonio','lic_rd_gonio','lic_sa_gonio','lic_sd_gonio');

save('Z:\Lab Member Folders\Blair Hu\Open Source Dataset 2017\ENABL3S\all_LW_EMG.mat','R_stance_fnames','R_stance_emg','L_stance_fnames','L_stance_emg','R_swing_fnames','R_swing_emg','L_swing_fnames','L_swing_emg');
save('Z:\Lab Member Folders\Blair Hu\Open Source Dataset 2017\ENABL3S\all_LW_GONIO.mat','R_stance_fnames','R_stance_gonio','L_stance_fnames','L_stance_gonio','R_swing_fnames','R_swing_gonio','L_swing_fnames','L_swing_gonio');
end