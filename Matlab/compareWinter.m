load('all_LW_GONIO.mat')
load('all_LW_EMG.mat')
load('AllSubjMVC.mat')
load('Winter_Ankle_Knee.mat')

lw_stance_knee = [];
lw_stance_ankle = [];
lw_stance_TA = [];
lw_stance_MG = [];
lw_stance_BF = [];
lw_stance_VL = [];

lw_swing_knee = [];
lw_swing_ankle = [];
lw_swing_TA = [];
lw_swing_MG = [];
lw_swing_BF = [];
lw_swing_VL = [];

subjID = {'AB156','AB185','AB186','AB188','AB189','AB190','AB191','AB192','AB193','AB194'};

for i = 1:size(R_stance_gonio,1)
   lw_stance_knee = [lw_stance_knee -interp1(linspace(1,600,size(R_stance_gonio{i},1)),R_stance_gonio{i}(:,2),1:600)'];
   lw_stance_ankle = [lw_stance_ankle -interp1(linspace(1,600,size(R_stance_gonio{i},1)),R_stance_gonio{i}(:,1),1:600)'];   
   
   subjnum = R_stance_fnames{1}(1:5);
   subjrow = find(strcmp(subjID,subjnum));
   norm_col = [subjMVC_max(subjrow,1) subjMVC_max(subjrow,2) subjMVC_max(subjrow,4) subjMVC_max(subjrow,6)];
   
   lw_stance_TA = [lw_stance_TA interp1(linspace(1,600,size(R_stance_emg{i},1)),R_stance_emg{i}(:,1),1:600)'/norm_col(1)];   
   lw_stance_MG = [lw_stance_MG interp1(linspace(1,600,size(R_stance_emg{i},1)),R_stance_emg{i}(:,2),1:600)'/norm_col(2)];  
   lw_stance_BF = [lw_stance_BF interp1(linspace(1,600,size(R_stance_emg{i},1)),R_stance_emg{i}(:,4),1:600)'/norm_col(3)];  
   lw_stance_VL = [lw_stance_VL interp1(linspace(1,600,size(R_stance_emg{i},1)),R_stance_emg{i}(:,6),1:600)'/norm_col(4)];  
end

for i = 1:size(L_stance_gonio,1)
   lw_stance_knee = [lw_stance_knee -interp1(linspace(1,600,size(L_stance_gonio{i},1)),L_stance_gonio{i}(:,2),1:600)'];
   lw_stance_ankle = [lw_stance_ankle -interp1(linspace(1,600,size(L_stance_gonio{i},1)),L_stance_gonio{i}(:,1),1:600)'];
   
   subjnum = L_stance_fnames{1}(1:5);
   subjrow = find(strcmp(subjID,subjnum));
   norm_col = [subjMVC_max(subjrow,8) subjMVC_max(subjrow,9) subjMVC_max(subjrow,11) subjMVC_max(subjrow,13)];
   
   lw_stance_TA = [lw_stance_TA interp1(linspace(1,600,size(L_stance_emg{i},1)),L_stance_emg{i}(:,1),1:600)'/norm_col(1)];   
   lw_stance_MG = [lw_stance_MG interp1(linspace(1,600,size(L_stance_emg{i},1)),L_stance_emg{i}(:,2),1:600)'/norm_col(2)];  
   lw_stance_BF = [lw_stance_BF interp1(linspace(1,600,size(L_stance_emg{i},1)),L_stance_emg{i}(:,4),1:600)'/norm_col(3)];  
   lw_stance_VL = [lw_stance_VL interp1(linspace(1,600,size(L_stance_emg{i},1)),L_stance_emg{i}(:,6),1:600)'/norm_col(4)];  
end

for i = 1:size(R_swing_gonio,1)
   lw_swing_knee = [lw_swing_knee -interp1(linspace(1,400,size(R_swing_gonio{i},1)),R_swing_gonio{i}(:,2),1:400)'];
   lw_swing_ankle = [lw_swing_ankle -interp1(linspace(1,400,size(R_swing_gonio{i},1)),R_swing_gonio{i}(:,1),1:400)'];
   
   subjnum = R_swing_fnames{1}(1:5);
   subjrow = find(strcmp(subjID,subjnum));
   norm_col = [subjMVC_max(subjrow,1) subjMVC_max(subjrow,2) subjMVC_max(subjrow,4) subjMVC_max(subjrow,6)];
   
   lw_swing_TA = [lw_swing_TA interp1(linspace(1,400,size(R_swing_emg{i},1)),R_swing_emg{i}(:,1),1:400)'/norm_col(1)];   
   lw_swing_MG = [lw_swing_MG interp1(linspace(1,400,size(R_swing_emg{i},1)),R_swing_emg{i}(:,2),1:400)'/norm_col(2)];  
   lw_swing_BF = [lw_swing_BF interp1(linspace(1,400,size(R_swing_emg{i},1)),R_swing_emg{i}(:,4),1:400)'/norm_col(3)];  
   lw_swing_VL = [lw_swing_VL interp1(linspace(1,400,size(R_swing_emg{i},1)),R_swing_emg{i}(:,6),1:400)'/norm_col(4)];  
end

for i = 1:size(L_swing_gonio,1)
   lw_swing_knee = [lw_swing_knee -interp1(linspace(1,400,size(L_swing_gonio{i},1)),L_swing_gonio{i}(:,2),1:400)'];
   lw_swing_ankle = [lw_swing_ankle -interp1(linspace(1,400,size(L_swing_gonio{i},1)),L_swing_gonio{i}(:,1),1:400)'];
   
   subjnum = L_swing_fnames{1}(1:5);
   subjrow = find(strcmp(subjID,subjnum));
   norm_col = [subjMVC_max(subjrow,8) subjMVC_max(subjrow,9) subjMVC_max(subjrow,11) subjMVC_max(subjrow,13)];
   
   lw_swing_TA = [lw_swing_TA interp1(linspace(1,400,size(L_swing_emg{i},1)),L_swing_emg{i}(:,1),1:400)'/norm_col(1)];   
   lw_swing_MG = [lw_swing_MG interp1(linspace(1,400,size(L_swing_emg{i},1)),L_swing_emg{i}(:,2),1:400)'/norm_col(2)];  
   lw_swing_BF = [lw_swing_BF interp1(linspace(1,400,size(L_swing_emg{i},1)),L_swing_emg{i}(:,4),1:400)'/norm_col(3)];  
   lw_swing_VL = [lw_swing_VL interp1(linspace(1,400,size(L_swing_emg{i},1)),L_swing_emg{i}(:,6),1:400)'/norm_col(4)];  
end

Gonio_mean_knee = [mean(lw_stance_knee,2); mean(lw_swing_knee,2)];
Gonio_mean_ankle = [mean(lw_stance_ankle,2); mean(lw_swing_ankle,2)];
EMG_mean_TA = [mean(lw_stance_TA,2); mean(lw_swing_TA,2)];
EMG_mean_MG = [mean(lw_stance_MG,2); mean(lw_swing_MG,2)];
EMG_mean_BF = [mean(lw_stance_BF,2); mean(lw_swing_BF,2)];
EMG_mean_VL = [mean(lw_stance_VL,2); mean(lw_swing_VL,2)];

Winter_ankle_1000 = interp1(linspace(1,1000,70),Winter_ankle_knee(:,1),1:1000)';
Winter_knee_1000 = interp1(linspace(1,1000,70),Winter_ankle_knee(:,2),1:1000)';

knee_stance_rms = sqrt(sum((Gonio_mean_knee(1:600)-Winter_knee_1000(1:600)).^2)/600);
knee_swing_rms = sqrt(sum((Gonio_mean_knee(600:1000)-Winter_knee_1000(600:1000)).^2)/400);
ankle_stance_rms = sqrt(sum((Gonio_mean_ankle(1:600)-Winter_ankle_1000(1:600)).^2)/600);
ankle_swing_rms = sqrt(sum((Gonio_mean_ankle(600:1000)-Winter_ankle_1000(600:1000)).^2)/400);

knee_stance_corrcoef = corrcoef(Gonio_mean_knee(1:600),Winter_knee_1000(1:600));
knee_swing_corrcoef = corrcoef(Gonio_mean_knee(600:1000),Winter_knee_1000(600:1000));
ankle_stance_corrcoef = corrcoef(Gonio_mean_ankle(1:600),Winter_ankle_1000(1:600));
ankle_swing_corrcoef = corrcoef(Gonio_mean_ankle(600:1000),Winter_ankle_1000(600:1000));

knee_inital_mean = mean(lw_stance_knee(1,:));
knee_initial_sd = std(lw_stance_knee(1,:));

knee_flex_stance_mean = mean(max(lw_stance_knee));
knee_flex_stance_sd = std(max(lw_stance_knee));
knee_ext_stance_mean = mean(min(lw_stance_knee));
knee_ext_stance_sd = std(min(lw_stance_knee));

knee_flex_swing_mean = mean(max(lw_swing_knee));
knee_flex_swing_sd = std(max(lw_swing_knee));
knee_ext_swing_mean = mean(min(lw_swing_knee));
knee_ext_swing_sd = std(min(lw_swing_knee));

% Plot knee (stance)
figure;
plot(lw_stance_knee,'Color',[0 0.6 0 0.01])
hold on;
plot(mean(lw_stance_knee,2),'Color',[0 0.5 0],'LineWidth',2)
plot(mean(lw_stance_knee,2)+std(lw_stance_knee,0,2),'Color',[0 0.5 0],'LineWidth',2,'LineStyle','--')
plot(mean(lw_stance_knee,2)-std(lw_stance_knee,0,2),'Color',[0 0.5 0],'LineWidth',2,'LineStyle','--')
plot(Winter_knee_1000(1:600),'k','LineWidth',2)
xlim([0 600])
ylim([-15 75])
xticks([0 100 200 300 400 500 600])
xticklabels({'0','10','20','30','40','50','60'})
xlabel('Gait cycle (%)');
ylabel('Knee angle (deg)');
title('Stance')
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')

% Plot knee (swing)
figure;
plot(lw_swing_knee,'Color',[0 0.6 0 0.01])
hold on;
plot(mean(lw_swing_knee,2),'Color',[0 0.5 0],'LineWidth',2)
plot(mean(lw_swing_knee,2)+std(lw_swing_knee,0,2),'Color',[0 0.5 0],'LineWidth',2,'LineStyle','--')
plot(mean(lw_swing_knee,2)-std(lw_swing_knee,0,2),'Color',[0 0.5 0],'LineWidth',2,'LineStyle','--')
plot(Winter_knee_1000(600:1000),'k','LineWidth',2)
xlim([0 400])
ylim([-15 75])
xticks([0 100 200 300 400])
xticklabels({'60','70','80','90','100'})
xlabel('Gait cycle (%)');
ylabel('Knee angle (deg)');
title('Swing')
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')

% Plot EMG (stance/swing)
figure;
subplot(221)
plot(lw_stance_TA,'Color',[0 0 0.6 0.01])
hold on;
plot(mean(lw_stance_TA,2),'Color',[0 0 0.5],'LineWidth',2)
plot(mean(lw_stance_TA,2)+std(lw_stance_TA,0,2),'Color',[0 0 0.5],'LineWidth',2,'LineStyle','--')
xlim([0 600])
ylim([-0.05 1.2])
xticks([0 100 200 300 400 500 600])
xticklabels({'','','','','','',''})
ylabel('TA (Norm.)');
title('Stance')
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')

subplot(222)
plot(lw_swing_TA,'Color',[0 0 0.6 0.01])
hold on;
plot(mean(lw_swing_TA,2),'Color',[0 0 0.5],'LineWidth',2)
plot(mean(lw_swing_TA,2)+std(lw_swing_TA,0,2),'Color',[0 0 0.5],'LineWidth',2,'LineStyle','--')
xlim([0 400])
ylim([-0.05 1.2])
xticks([0 100 200 300 400])
xticklabels({'','','','',''})
title('Swing')
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')

subplot(223)
plot(lw_stance_MG,'Color',[0 0 0.6 0.01])
hold on;
plot(mean(lw_stance_MG,2),'Color',[0 0 0.5],'LineWidth',2)
plot(mean(lw_stance_MG,2)+std(lw_stance_MG,0,2),'Color',[0 0 0.5],'LineWidth',2,'LineStyle','--')
xlim([0 600])
ylim([-0.05 2])
xticks([0 100 200 300 400 500 600])
xticklabels({'0','10','20','30','40','50','60'})
xlabel('Gait cycle (%)');
ylabel('MG (Norm.)');
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')

subplot(224)
plot(lw_swing_MG,'Color',[0 0 0.6 0.01])
hold on;
plot(mean(lw_swing_MG,2),'Color',[0 0 0.5],'LineWidth',2)
plot(mean(lw_swing_MG,2)+std(lw_swing_MG,0,2),'Color',[0 0 0.5],'LineWidth',2,'LineStyle','--')
xlim([0 400])
ylim([-0.05 2])
xticks([0 100 200 300 400])
xticklabels({'60','70','80','90','100'})
xlabel('Gait cycle (%)');
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')

figure()
subplot(221)
plot(lw_stance_BF,'Color',[0 0 0.6 0.01])
hold on;
plot(mean(lw_stance_BF,2),'Color',[0 0 0.5],'LineWidth',2)
plot(mean(lw_stance_BF,2)+std(lw_stance_BF,0,2),'Color',[0 0 0.5],'LineWidth',2,'LineStyle','--')
xlim([0 600])
ylim([-0.05 1.2])
xticks([0 100 200 300 400 500 600])
xticklabels({'','','','','','',''})
ylabel('BF (Norm.)');
title('Stance')
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')

subplot(222)
plot(lw_swing_BF,'Color',[0 0 0.6 0.01])
hold on;
plot(mean(lw_swing_BF,2),'Color',[0 0 0.5],'LineWidth',2)
plot(mean(lw_swing_BF,2)+std(lw_swing_BF,0,2),'Color',[0 0 0.5],'LineWidth',2,'LineStyle','--')
xlim([0 400])
ylim([-0.05 1.2])
xticks([0 100 200 300 400])
xticklabels({'','','','',''})
title('Swing')
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')

subplot(223)
plot(lw_stance_VL,'Color',[0 0 0.6 0.01])
hold on;
plot(mean(lw_stance_VL,2),'Color',[0 0 0.5],'LineWidth',2)
plot(mean(lw_stance_VL,2)+std(lw_stance_VL,0,2),'Color',[0 0 0.5],'LineWidth',2,'LineStyle','--')
xlim([0 600])
ylim([-0.05 1.5])
xticks([0 100 200 300 400 500 600])
xticklabels({'0','10','20','30','40','50','60'})
xlabel('Gait cycle (%)');
ylabel('VL (Norm.)');
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')

subplot(224)
plot(lw_swing_VL,'Color',[0 0 0.6 0.01])
hold on;
plot(mean(lw_swing_VL,2),'Color',[0 0 0.5],'LineWidth',2)
plot(mean(lw_swing_VL,2)+std(lw_swing_VL,0,2),'Color',[0 0 0.5],'LineWidth',2,'LineStyle','--')
xlim([0 400])
ylim([-0.05 1.5])
xticks([0 100 200 300 400])
xticklabels({'60','70','80','90','100'})
xlabel('Gait cycle (%)');
set(gca, 'FontName', 'Palatino Linotype','FontSize',16,'FontWeight','bold')