% RIGHT
% 31: TA
% 32: MG
% 33: SOL
% 34: BF
% 35: ST
% 36: VL
% 37: RF

% LEFT
% 39: TA
% 40: MG
% 41: SOL
% 42: BF
% 43: ST
% 45: VL
% 46: RF

subjID = 'AB194';

fpath = ['Z:\Lab Member Folders\Blair Hu\Open Source Dataset 2017\Subject\',subjID,'\MVC\'];

load([fpath,'R_Plantar_MVC_001.mat']); % Channel 32/33
load([fpath,'R_Dorsi_MVC_001.mat']); % Channel 31
load([fpath,'R_Extensor_MVC_001.mat']); % Channel 36/37
load([fpath,'R_Flexor_MVC_001.mat']); % Channel 34/35

load([fpath,'L_Plantar_MVC_001.mat']); % Channel 40/41
load([fpath,'L_Dorsi_MVC_001.mat']); % Channel 39
load([fpath,'L_Extensor_MVC_001.mat']); % Channel 45/46
load([fpath,'L_Flexor_MVC_001.mat']); % Channel 42/43

% load([fpath,'RL_Plantar_MVC_001.mat']); % Channel 32/33 and  40/41
% eval('RMG = RL_Plantar_MVC_001.daq.DAQ_DATA(:,32);');
% eval('RSOL = RL_Plantar_MVC_001.daq.DAQ_DATA(:,33);');
% eval('LMG = RL_Plantar_MVC_001.daq.DAQ_DATA(:,40);');
% eval('LSOL = RL_Plantar_MVC_001.daq.DAQ_DATA(:,41);');

eval('RTA = R_Dorsi_MVC_001.daq.DAQ_DATA(:,31);');
eval('RMG = R_Plantar_MVC_001.daq.DAQ_DATA(:,32);');
eval('RSOL = R_Plantar_MVC_001.daq.DAQ_DATA(:,33);');
eval('RBF = R_Flexor_MVC_001.daq.DAQ_DATA(:,34);');
eval('RST = R_Flexor_MVC_001.daq.DAQ_DATA(:,35);');
eval('RVL = R_Extensor_MVC_001.daq.DAQ_DATA(:,36);');
eval('RRF = R_Extensor_MVC_001.daq.DAQ_DATA(:,37);');

eval('LTA = L_Dorsi_MVC_001.daq.DAQ_DATA(:,39);');
eval('LMG = L_Plantar_MVC_001.daq.DAQ_DATA(:,40);');
eval('LSOL = L_Plantar_MVC_001.daq.DAQ_DATA(:,41);');
eval('LBF = L_Flexor_MVC_001.daq.DAQ_DATA(:,42);');
eval('LST = L_Flexor_MVC_001.daq.DAQ_DATA(:,43);');
eval('LVL = L_Extensor_MVC_001.daq.DAQ_DATA(:,45);');
eval('LRF = L_Extensor_MVC_001.daq.DAQ_DATA(:,46);');

RTA_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],RTA);
RMG_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],RMG);
RSOL_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],RSOL);
RBF_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],RBF);
RST_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],RST);
RVL_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],RVL);
RRF_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],RRF);

LTA_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],LTA);
LMG_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],LMG);
LSOL_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],LSOL);
LBF_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],LBF);
LST_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],LST);
LVL_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],LVL);
LRF_filt = EMGfilt(1000,4,20,350,[57 177 297],[63 183 303],LRF);

header = {'RTA' 'RMG' 'RSOL' 'RBF' 'RST' 'RVL' 'RRF' 'LTA' 'LMG' 'LSOL' 'LBF' 'LST' 'LVL' 'LRF'};
output = nan(30000,14);

output(1:length(RTA_filt),1) = RTA_filt;
output(1:length(RMG_filt),2) = RMG_filt;
output(1:length(RSOL_filt),3) = RSOL_filt;
output(1:length(RBF_filt),4) = RBF_filt;
output(1:length(RST_filt),5) = RST_filt;
output(1:length(RVL_filt),6) = RVL_filt;
output(1:length(RRF_filt),7) = RRF_filt;

output(1:length(LTA_filt),8) = LTA_filt;
output(1:length(LMG_filt),9) = LMG_filt;
output(1:length(LSOL_filt),10) = LSOL_filt;
output(1:length(LBF_filt),11) = LBF_filt;
output(1:length(LST_filt),12) = LST_filt;
output(1:length(LVL_filt),13) = LVL_filt;
output(1:length(LRF_filt),14) = LRF_filt;

T_MVC = array2table(output,'VariableNames',header);
writetable(T_MVC,[subjID,'_MVC.csv','Delimiter',',']