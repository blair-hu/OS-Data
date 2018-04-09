load('C:\Users\bhu\Git\Open_Source\Data\Meta\checkGONIO.mat')
load('C:\Users\bhu\Git\Open_Source\Data\Meta\checkEMG.mat')

subjstr = {'AB156','AB185','AB186','AB188','AB189','AB190','AB191','AB192','AB193','AB194'};

gonio_header = {'R_Ankle_Mean','R_Knee_Mean','L_Ankle_Mean','L_Knee_Mean',...
    'R_Ankle_SD','R_Knee_SD','L_Ankle_SD','L_Knee_SD',...
    'R_Ankle_Min','R_Knee_Min','L_Ankle_Min','L_Knee_Min',...
    'R_Ankle_Max','R_Knee_Max','L_Ankle_Max','L_Knee_Max'};
emg_header = {'RTA_SNR','RMG_SNR','RSOL_SNR','RBF_SNR','RST_SNR','RVL_SNR','RRF_SNR',...
    'LTA_SNR','LMG_SNR','LSOL_SNR','LBF_SNR','LST_SNR','LVL_SNR','LRF_SNR'};

meta_header = ['Filename' gonio_header emg_header];

for i = 1:length(fnames)
    fnames{i} = fnames{i}(1:17);
end

for i = 1:10
    output = {};
    
    subjinds= find(contains(fnames,subjstr{i}));
    output = [fnames(subjinds) num2cell(GONIO_MEAN(subjinds,:)) num2cell(GONIO_SD(subjinds,:)) num2cell(GONIO_MIN(subjinds,:)) num2cell(GONIO_MAX(subjinds,:)) num2cell(EMG_SNR(subjinds,:))];
    
    T_META = array2table(output,'VariableNames',meta_header);
    writetable(T_META,[subjstr{i},'_Metadata.csv'],'Delimiter',',')
end