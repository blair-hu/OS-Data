function [gonio_feats,gonio_feats_label] = getGONIOfeats(input,chan_select,feat_select)
% Function: Perform feature extraction for GONIO channels

% Input: Processed signals, channel indices, and feature indices
% Output: gonio_feats matrix (instances x features) and gonio_feats_label cell
% array (names of channels/features)

% Function dependencies:
% NONE

%%%%%
% Documented by: Blair Hu 08/04/17
%%%%%

% Mean
gonio_avg = mean(input);
% Min
gonio_min = min(input);
% Max
gonio_max = max(input);
% Initial
gonio_initial = input(1,:);
% Final
gonio_final = input(end,:);
% Std Dev
gonio_sd = std(input,[],1);

feats_all{1} = gonio_avg;
feats_all{2} = gonio_min;
feats_all{3} = gonio_max;
feats_all{4} = gonio_initial;
feats_all{5} = gonio_final;
feats_all{6} = gonio_sd;

chan_str{1} = 'Ipsi Ankle ';
chan_str{2} = 'Ipsi Knee ';
chan_str{3} = 'Contra Ankle ';
chan_str{4} = 'Contra Knee ';
chan_str{5} = 'Ipsi Ankle Vel ';
chan_str{6} = 'Ipsi Knee Vel ';
chan_str{7} = 'Contra Ankle Vel ';
chan_str{8} = 'Contra Knee Vel ';

feats_str{1} = 'Mean';
feats_str{2} = 'Min';
feats_str{3} = 'Max';
feats_str{4} = 'Initial';
feats_str{5} = 'Final';
feats_str{6} = 'Std Dev';

gonio_feats = [];
gonio_feats_label = {};
for i = 1:length(feat_select)
    gonio_feats = [gonio_feats feats_all{feat_select(i)}];
    for j = 1:length(chan_select)
        gonio_feats_label = [gonio_feats_label; [chan_str{chan_select(j)},feats_str{feat_select(i)}]];
    end    
end
end