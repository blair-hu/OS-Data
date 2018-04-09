function [emg_feats,emg_feats_label] = getEMGfeats(input,chan_select,feat_select)
% Function: Perform feature extraction for EMG channels

% Input: Processed signals, channel indices, and feature indices
% criterion
% Output: emg_feats matrix (instances x features) and emg_feats_label cell
% array (names of channels/features)

% Function dependencies:
% getTDfeats.m
% getARfeats.m

%%%%%
% Documented by: Blair Hu 08/04/17
%%%%%

TDfeats = getTDfeats(input);
ARfeats = getARfeats(input,6,6);

feats_all{1} = TDfeats(1,:);
feats_all{2} = TDfeats(2,:);
feats_all{3} = TDfeats(3,:);
feats_all{4} = TDfeats(4,:);
feats_all{5} = ARfeats(1,:);
feats_all{6} = ARfeats(2,:);
feats_all{7} = ARfeats(3,:);
feats_all{8} = ARfeats(4,:);
feats_all{9} = ARfeats(5,:);
feats_all{10} = ARfeats(6,:);

chan_str{1} = 'Ipsi TA ';
chan_str{2} = 'Ipsi MG ';
chan_str{3} = 'Ipsi SOL ';
chan_str{4} = 'Ipsi BF ';
chan_str{5} = 'Ipsi ST ';
chan_str{6} = 'Ipsi VL ';
chan_str{7} = 'Ipsi RF ';
chan_str{8} = 'Contra TA ';
chan_str{9} = 'Contra MG ';
chan_str{10} = 'Contra SOL ';
chan_str{11} = 'Contra BF ';
chan_str{12} = 'Contra ST ';
chan_str{13} = 'Contra VL ';
chan_str{14} = 'Contra RF ';

feats_str{1} = 'MAV';
feats_str{2} = 'Waveform Length';
feats_str{3} = 'Slope Sign Changes';
feats_str{4} = 'Zero Crossings';
feats_str{5} = 'AR1';
feats_str{6} = 'AR2';
feats_str{7} = 'AR3';
feats_str{8} = 'AR4';
feats_str{9} = 'AR5';
feats_str{10} = 'AR6';

emg_feats = [];
emg_feats_label = {};
for i = 1:length(feat_select)
    emg_feats = [emg_feats feats_all{feat_select(i)}];
    for j = 1:length(chan_select)
        emg_feats_label = [emg_feats_label; [chan_str{chan_select(j)},feats_str{feat_select(i)}]];
    end
end
end