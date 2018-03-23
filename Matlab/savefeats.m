subjstr = 'AB194';
load([subjstr,'_feats_reprocessed.mat']);

feats0 = feats{1};
feats30 = feats{2};
feats60 = feats{3};
feats90 = feats{4};
feats120 = feats{5};

trig_num = cellfun(@str2num,trig);

output0 = [feats0 legphase trig_num];
output30 = [feats30 legphase trig_num];
output60 = [feats60 legphase trig_num];
output90 = [feats90 legphase trig_num];
output120 = [feats120 legphase trig_num];

header = [featlabels' 'Leg Phase' 'Trigger'];

T0 = array2table(output0,'VariableNames',header);
writetable(T0,[subjstr,'_Features_300.csv'],'Delimiter',',')
T30 = array2table(output30,'VariableNames',header);
writetable(T30,[subjstr,'_Features_270.csv'],'Delimiter',',')
T60 = array2table(output60,'VariableNames',header);
writetable(T60,[subjstr,'_Features_240.csv'],'Delimiter',',')
T90 = array2table(output90,'VariableNames',header);
writetable(T90,[subjstr,'_Features_210.csv'],'Delimiter',',')
T120 = array2table(output120,'VariableNames',header);
writetable(T120,[subjstr,'_Features_180.csv'],'Delimiter',',')