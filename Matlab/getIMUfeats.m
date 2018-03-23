function [imu_feats,imu_feats_label] = getIMUfeats(input,chan_select,feat_select)
% Function: Perform feature extraction for IMU channels

% Input: Processed signals, channel indices, and feature indices
% criterion
% Output: emg_feats matrix (instances x features) and emg_feats_label cell
% array (names of channels/features)

% Function dependencies:
% NONE

%%%%%
% Documented by: Blair Hu 08/04/17
%%%%%

% Mean
imu_avg = mean(input);
% Min
imu_min = min(input);
% Max
imu_max = max(input);
% Initial
imu_initial = input(1,:);
% Final
imu_final = input(end,:);
% Std Dev
imu_sd = std(input,[],1);

feats_all{1} = imu_avg;
feats_all{2} = imu_min;
feats_all{3} = imu_max;
feats_all{4} = imu_initial;
feats_all{5} = imu_final;
feats_all{6} = imu_sd;

chan_str{1} = 'Ipsi Shank Ax ';
chan_str{2} = 'Ipsi Shank Ay ';
chan_str{3} = 'Ipsi Shank Az ';
chan_str{4} = 'Ipsi Shank Gy ';
chan_str{5} = 'Ipsi Shank Gz ';
chan_str{6} = 'Ipsi Shank Gx ';
chan_str{7} = 'Ipsi Thigh Ax ';
chan_str{8} = 'Ipsi Thigh Ay ';
chan_str{9} = 'Ipsi Thigh Az ';
chan_str{10} = 'Ipsi Thigh Gy ';
chan_str{11} = 'Ipsi Thigh Gz ';
chan_str{12} = 'Ipsi Thigh Gx ';
chan_str{13} = 'Contra Shank Ax ';
chan_str{14} = 'Contra Shank Ay ';
chan_str{15} = 'Contra Shank Az ';
chan_str{16} = 'Contra Shank Gy ';
chan_str{17} = 'Contra Shank Gz ';
chan_str{18} = 'Contra Shank Gx ';
chan_str{19} = 'Contra Thigh Ax ';
chan_str{20} = 'Contra Thigh Ay ';
chan_str{21} = 'Contra Thigh Az ';
chan_str{22} = 'Contra Thigh Gy ';
chan_str{23} = 'Contra Thigh Gz ';
chan_str{24} = 'Contra Thigh Gx ';
chan_str{25} = 'Waist Ax ';
chan_str{26} = 'Waist Ay ';
chan_str{27} = 'Waist Az ';
chan_str{28} = 'Waist Gy ';
chan_str{29} = 'Waist Gz ';
chan_str{30} = 'Waist Gx ';

feats_str{1} = 'Mean';
feats_str{2} = 'Min';
feats_str{3} = 'Max';
feats_str{4} = 'Initial';
feats_str{5} = 'Final';
feats_str{6} = 'Std Dev';

imu_feats = [];
imu_feats_label = {};
for i = 1:length(feat_select)
    imu_feats = [imu_feats feats_all{feat_select(i)}];
    for j = 1:length(chan_select)
        imu_feats_label = [imu_feats_label; [chan_str{chan_select(j)},feats_str{feat_select(i)}]];
    end
end
end