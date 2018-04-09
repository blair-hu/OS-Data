function getsegmentedfromraw
% Function: take all raw data (in the form of Circuit_XXX.mat) from a single subject and perform
% step segmentation, feature extraction, and save new files to be used for
% classification (requires experimental notes for confirming segmenting
% steps)

% Input: None (to be selected using GUI)
% Output: ABXXX_toclassify.mat and CircuitXXX_resegmented.mat

% Function dependencies:
% uipickfiles.m
% LPfilt.m
% HPfilt.m
% NOTCHfilt.m
% extractfeats_mat.m

%%%%%
% Documented by: Blair Hu 08/04/17
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

for i = 1:length(files)
    close all
    % Load raw data
    filestruct = load(files{i});
    [fpath,fname,fext] = fileparts(files{i});
    cd(fpath);
    disp(fname);
    
    subjID_ind = findstr('AB',fpath);
    subjID = fpath(subjID_ind:(subjID_ind+4));
    
    eval(['F_s = filestruct.' fname '.setup.DAQ_SAMP;']);
    eval(['fr_cnt = filestruct.' fname '.pvd.FRAME_CNT;']);
    eval(['fr_inc = filestruct.' fname '.setup.DAQ_FRINC;']);
    
    % Interpolate the mode data
    eval(['MODE_PVD = filestruct.' fname '.pvd.MODE;']);
    MODE_DAQ = [];
    for j = 1:length(fr_cnt)
        MODE_DAQ = [MODE_DAQ; repmat(MODE_PVD(j), fr_inc, 1)];
    end
    MODE_DAQ(MODE_DAQ == 0.5) = 6; % Relabel standing to 6
    
    % Refer to "Gait Mode Bilateral Data Collection Protocol" for channel
    % listings
    
    %%%%% IMU %%%%%
    eval(['IMU_DAQUINT = filestruct.' fname '.daq.daqUINT16(:,1:30);']);
    IMU_DAQ_CHAN = [];
    % Use the scalings from the MyoIMU spec sheet for accelerometer and
    % gyroscope channels
    IMU_DAQ_CHAN(:,[1:3 7:9 13:15 19:21 25:27]) = (double(IMU_DAQUINT(:,[1:3 7:9 13:15 19:21 25:27]))-32768)/8192;
    IMU_DAQ_CHAN(:,[4:6 10:12 16:18 22:24 28:30]) = (double(IMU_DAQUINT(:,[4:6 10:12 16:18 22:24 28:30]))-32768)/65.536;
    %%%%%%%%%%%%%%%
    
    %%%%% GONIO %%%%%
    eval(['GONIO_DAQ_CHAN = filestruct.' fname '.daq.DAQ_DATA(:,[47:50]);']);
    % Use the scaling from the Biometrics goniometer manual
    GONIO_DAQ_CHAN = (GONIO_DAQ_CHAN-2)*90;
    % Reverse signals for one side
    GONIO_DAQ_CHAN(:,2) = -GONIO_DAQ_CHAN(:,2);
    %%%%%%%%%%%%%%%%%
    
    %%%%% EMG %%%%%
    eval(['EMG_DAQ_CHAN = filestruct.' fname '.daq.DAQ_DATA(:,[31:37 39:43 45:46]);']);
    %%%%%%%%%%%%%%%
    
    %%%%% FOOTSWITCH %%%%%
    eval(['FS_DAQ_CHAN = filestruct.' fname '.daq.DAQ_DATA(:,[51:54]);']);
    FS_DAQ_CHAN_LP = LPfilt(F_s,1,50,FS_DAQ_CHAN);
    R_FS = or(FS_DAQ_CHAN_LP(:,1)>4,FS_DAQ_CHAN_LP(:,2)>4);
    L_FS = or(FS_DAQ_CHAN_LP(:,3)>4,FS_DAQ_CHAN_LP(:,4)>4);
    %%%%%%%%%%%%%%%%%%%%%%
    
    %% Filter data
    %%%%% IMU %%%%%
    % Low-pass filter (6 Hz)-  gyroscope signals only for gait segmentation
    IMU_DAQ_CHAN_LPSHANK = [];
    IMU_DAQ_CHAN_LPSHANK(:,[1:6 10:12 13:18 22:24 28:30]) = LPfilt(F_s,1,6,IMU_DAQ_CHAN(:,[1:6 10:12 13:18 22:24 28:30]));
    
    IMU_DAQ_CHAN_LP = [];
    IMU_DAQ_CHAN_LP = LPfilt(F_s,6,25,IMU_DAQ_CHAN);
    
    % Get shank velocity for gait segmentation
    R_Shank_Vel = IMU_DAQ_CHAN_LPSHANK(:,4);
    L_Shank_Vel = IMU_DAQ_CHAN_LPSHANK(:,16);
    % Remove mean offset
    R_Shank_Vel = R_Shank_Vel - mean(R_Shank_Vel);
    L_Shank_Vel = L_Shank_Vel - mean(L_Shank_Vel);
    
    % Find and threshold peaks in shank velocity
    [R_pospeaks] = findpeaks(R_Shank_Vel);
    [R_negpeaks] = findpeaks(-R_Shank_Vel);
    [L_pospeaks] = findpeaks(L_Shank_Vel);
    [L_negpeaks] = findpeaks(-L_Shank_Vel);
    
    R_pospeaks = R_pospeaks(R_pospeaks > 100);
    R_negpeaks = R_negpeaks(R_negpeaks > 100);    
    L_pospeaks = L_pospeaks(L_pospeaks > 100);
    L_negpeaks = L_negpeaks(L_negpeaks > 100); 
    
    % Determine if the shank velocity signal is inverted; if so, correct it
    if mean(R_negpeaks) > mean(R_pospeaks)
        R_Shank_Vel = -R_Shank_Vel;
    end
    if mean(L_negpeaks) > mean(L_pospeaks)
        L_Shank_Vel = -L_Shank_Vel;
    end
    %%%%%%%%%%%%%%%
    
    %%%%% GONIO %%%%%
    % Low-pass filter (10 Hz)
    GONIO_DAQ_CHAN_LP = LPfilt(F_s,6,10,GONIO_DAQ_CHAN);
    %%%%%%%%%%%%%%%%%
    
    % Calculate joint velocities and append
    VEL_DAQ_CHAN_LP = numderiv(GONIO_DAQ_CHAN_LP,F_s,0);
    
    %%%%% EMG %%%%%
    EMG_DAQ_CHAN_HP = HPfilt(F_s,6,20,EMG_DAQ_CHAN);
    EMG_DAQ_CHAN_HPNOTCH = NOTCHfilt(F_s,6,[57 177 297],[63 183 303],EMG_DAQ_CHAN_HP);
    %%%%%%%%%%%%%%%
    %% Get standing/sitting data using manual thresholds
    sitting = find((MODE_DAQ == 0) & (GONIO_DAQ_CHAN_LP(:,2) < -75) & (GONIO_DAQ_CHAN_LP(:,4) < -75));
    standing = find((MODE_DAQ == 6) & (GONIO_DAQ_CHAN_LP(:,2) > -10) & (GONIO_DAQ_CHAN_LP(:,4) > -10));
    
    % SITTING BEGINNING %
    sitting_beg = sitting(sitting < 0.5*length(MODE_DAQ));
    %%%%%%%%%%%%%%%%%%%%%
    
    % STANDING BEGINNING %
    standing_beg = standing(standing < 0.5*length(MODE_DAQ));
    %%%%%%%%%%%%%%%%%%%%%%
    
    % STANDING END %
    standing_end = standing(standing > 0.5*length(MODE_DAQ));
    %%%%%%%%%%%%%%%%
    
    % SITTING END %
    sitting_end = sitting(sitting > 0.5*length(MODE_DAQ));
    %%%%%%%%%%%%%%%
    %% Find gait events
    % Parameters (somewhat arbitrary, hand-tuned) for finding peaks
    MSw_Threshold = 100;
    MSw_Width = 150;
    MSw_Separation = 700;
    
    % Get gait events using shank velocity
    [R_IC,R_EC,R_MSw,R_IC_trig,R_EC_trig,R_MSw_trig] = getgaitevents(MODE_DAQ,R_Shank_Vel,MSw_Threshold, MSw_Width, MSw_Separation);
    [L_IC,L_EC,L_MSw,L_IC_trig,L_EC_trig,L_MSw_trig] = getgaitevents(MODE_DAQ,L_Shank_Vel,MSw_Threshold, MSw_Width, MSw_Separation);
    
    % Plot joint angles and identified gait events
    figure()
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    subplot(2,1,1)
    plot(R_Shank_Vel); hold on;
    title('RIGHT')
    plot(R_IC,R_Shank_Vel(R_IC),'xr');
    plot(R_EC,R_Shank_Vel(R_EC),'ob');
    plot(R_MSw,R_Shank_Vel(R_MSw),'+g');
    plot(20*MODE_DAQ+75,'k','LineWidth',1.5);
    R_IC_labels = cellstr(num2str([1:length(R_IC)]'));
    text(R_IC,R_Shank_Vel(R_IC)+1,R_IC_labels,'Color','r');
    R_EC_labels = cellstr(num2str([1:length(R_EC)]'));
    text(R_EC,R_Shank_Vel(R_EC)+1,R_EC_labels,'Color','b');
    R_MSw_labels = cellstr(num2str([1:length(R_MSw)]'));
    text(R_MSw,R_Shank_Vel(R_MSw)+1,R_MSw_labels,'Color','g');
    
    subplot(2,1,2)
    plot(GONIO_DAQ_CHAN(:,1)); hold on;
    plot(R_IC,GONIO_DAQ_CHAN(R_IC,1),'xr');
    plot(R_EC,GONIO_DAQ_CHAN(R_EC,1),'ob');
    plot(R_MSw,GONIO_DAQ_CHAN(R_MSw,1),'+g');
    plot(GONIO_DAQ_CHAN(:,2));
    plot(R_IC,GONIO_DAQ_CHAN(R_IC,2),'xr');
    plot(R_EC,GONIO_DAQ_CHAN(R_EC,2),'ob');
    plot(R_MSw,GONIO_DAQ_CHAN(R_MSw,2),'+g');
    plot(30*MODE_DAQ+10,'k','LineWidth',1.5);
    
    figure()
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    subplot(2,1,1)
    plot(L_Shank_Vel); hold on;
    title('LEFT')
    plot(L_IC,L_Shank_Vel(L_IC),'xr');
    plot(L_EC,L_Shank_Vel(L_EC),'ob');
    plot(L_MSw,L_Shank_Vel(L_MSw),'+g');
    plot(20*MODE_DAQ+75,'k','LineWidth',1.5);
    L_IC_labels = cellstr(num2str([1:length(L_IC)]'));
    text(L_IC,L_Shank_Vel(L_IC)+1,L_IC_labels,'Color','r');
    L_EC_labels = cellstr(num2str([1:length(L_EC)]'));
    text(L_EC,L_Shank_Vel(L_EC)+1,L_EC_labels,'Color','b');
    L_MSw_labels = cellstr(num2str([1:length(L_MSw)]'));
    text(L_MSw,L_Shank_Vel(L_MSw)+1,L_MSw_labels,'Color','g');
    
    subplot(2,1,2)
    plot(GONIO_DAQ_CHAN(:,3)); hold on;
    plot(L_IC,GONIO_DAQ_CHAN(L_IC,3),'xr');
    plot(L_EC,GONIO_DAQ_CHAN(L_EC,3),'ob');
    plot(L_MSw,GONIO_DAQ_CHAN(L_MSw,3),'+g');
    plot(GONIO_DAQ_CHAN(:,4));
    plot(L_IC,GONIO_DAQ_CHAN(L_IC,4),'xr');
    plot(L_EC,GONIO_DAQ_CHAN(L_EC,4),'ob');
    plot(L_MSw,GONIO_DAQ_CHAN(L_MSw,4),'+g');
    plot(30*MODE_DAQ+10,'k','LineWidth',1.5);
    
    % Use dialog box to allow user to confirm identified gait events and
    % remove false detections
    prompt = {'Filename:','Keep R IC:','Keep R EC:','Keep R MSw:','Keep L IC:','Keep L EC:','Keep L MSw:'};
    dlg_title = 'Input';
    num_lines = 1;
    defaultans = {fname,mat2str(1:length(R_IC)),mat2str(1:length(R_EC)),mat2str(1:length(R_MSw)),mat2str(1:length(L_IC)),mat2str(1:length(L_EC)),mat2str(1:length(L_MSw))};
	answer2 = inputdlg(prompt,dlg_title,num_lines,defaultans);
    R_IC_keep = str2num(answer2{2});   
    R_EC_keep = str2num(answer2{3});
    R_MSw_keep = str2num(answer2{4});
    L_IC_keep = str2num(answer2{5});
    L_EC_keep = str2num(answer2{6});
    L_MSw_keep = str2num(answer2{7});
    
    R_IC = R_IC(R_IC_keep);
    R_IC_trig = R_IC_trig(R_IC_keep);
    R_EC = R_EC(R_EC_keep);
    R_EC_trig = R_EC_trig(R_EC_keep);
    R_MSw = R_MSw(R_MSw_keep);
    R_MSw_trig = R_MSw_trig(R_MSw_keep);
    L_IC = L_IC(L_IC_keep);
    L_IC_trig = L_IC_trig(L_IC_keep);
    L_EC = L_EC(L_EC_keep);
    L_EC_trig = L_EC_trig(L_EC_keep);
    L_MSw = L_MSw(L_MSw_keep);       
    L_MSw_trig = L_MSw_trig(L_MSw_keep);
    %% Feature extraction    
    RorL = 1; % Right foot is ipsilateral
    [R_HC_feats,featlabels] = extractfeats_mat(IMU_DAQ_CHAN_LP,GONIO_DAQ_CHAN_LP,EMG_DAQ_CHAN_HPNOTCH,RorL,R_IC,WinLen,WinInc,MaxDelay);
    [R_TO_feats,~] = extractfeats_mat(IMU_DAQ_CHAN_LP,GONIO_DAQ_CHAN_LP,EMG_DAQ_CHAN_HPNOTCH,RorL,R_EC,WinLen,WinInc,MaxDelay);
    RorL = 2; % Left foot is ipsilateral
    [L_HC_feats,~] = extractfeats_mat(IMU_DAQ_CHAN_LP,GONIO_DAQ_CHAN_LP,EMG_DAQ_CHAN_HPNOTCH,RorL,L_IC,WinLen,WinInc,MaxDelay);
    [L_TO_feats,~] = extractfeats_mat(IMU_DAQ_CHAN_LP,GONIO_DAQ_CHAN_LP,EMG_DAQ_CHAN_HPNOTCH,RorL,L_EC,WinLen,WinInc,MaxDelay);
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
    %% Save file
    output_struct{1} = [fpath,fname];
    output_struct{2} = R_IC;
    output_struct{3} = R_IC_trig;
    output_struct{4} = R_EC;
    output_struct{5} = R_EC_trig;
    output_struct{6} = R_MSw;
    output_struct{7} = R_MSw_trig;
    output_struct{8} = L_IC;
    output_struct{9} = L_IC_trig;
    output_struct{10} = L_EC;
    output_struct{11} = L_EC_trig;
    output_struct{12} = L_MSw;
    output_struct{13} = L_MSw_trig;
    output_struct{14} = IMU_DAQ_CHAN_LP;
    output_struct{15} = EMG_DAQ_CHAN_HPNOTCH;
    output_struct{16} = GONIO_DAQ_CHAN_LP;
    output_struct{17} = MODE_DAQ;
    output_struct{18} = sitting_beg;
    output_struct{19} = standing_beg;   
    output_struct{20} = standing_end;
    output_struct{21} = sitting_end;
      
    save([fname,'_resegmented.mat'],'output_struct');
    
    clear filestruct
    clear output_struct
end
close all
end

function [HC,TO,MSw,HC_trig,TO_trig,MSw_trig] = getgaitevents(MODE_DAQ,Shank_Vel,MSw_Threshold,MSw_Width,MSw_Separation)
% First identify all mid-swing peaks (largest positive velocity)
[~,MSw] = findpeaks(Shank_Vel,'MinPeakHeight',MSw_Threshold,'MinPeakWidth',MSw_Width,'MinPeakDistance',MSw_Separation);
MSw = MSw(MODE_DAQ(MSw) > 0);

% Invert the shank velocity to make peak finding easier
Shank_Vel = -Shank_Vel;
HC = [];
TO = [];
for i = 1:length(MSw)
    currMSw = MSw(i);
    % Look for first large peak before each MSw event (represents toe off)
    counter = 0;
    while Shank_Vel(currMSw) < Shank_Vel(currMSw-1)
        currMSw = currMSw - 1;
        % Check if there is a turn in the monotonicity
        if Shank_Vel(currMSw) > Shank_Vel(currMSw-1)
            while Shank_Vel(currMSw) > Shank_Vel(currMSw-1)
                currMSw = currMSw - 1;
                counter = counter + 1;
                % Allow turns of up to 50 ms
                if counter > 50
                    currMSw = currMSw + counter;
                    counter = 0;
                    break
                end
            end
        end
    end
    TO = [TO; currMSw];
    % If there is another MSw event before, look for the first large peak before
    % the previous MSw event (represents heel contact)
    if i > 1
        prevMSw = MSw(i-1);
        tempstart = prevMSw;
        while Shank_Vel(tempstart) < Shank_Vel(tempstart+1)
            tempstart = tempstart + 1;
        end
        HCwindow = [prevMSw:(min(length(Shank_Vel),max(TO)))];
        [hcpeakheight,hcpeak] = findpeaks(Shank_Vel(HCwindow),'MinPeakProminence',20,'MinPeakWidth',50);
        if ~isempty(hcpeak)
            HC = [HC; prevMSw + hcpeak(find(hcpeakheight == max(hcpeakheight)))];
        else
            HC = [HC; tempstart];
        end
        % If this is the last MSw event, look for a heel contact event
        % afterwards
        if i == length(MSw)
            lastMSw = MSw(i);
            tempstart = lastMSw;
            while Shank_Vel(tempstart) < Shank_Vel(tempstart+1)
                tempstart = tempstart + 1;
            end
            HCwindow = [lastMSw:(min(length(Shank_Vel),(lastMSw+500)))];
            [hcpeakheight,hcpeak] = findpeaks(Shank_Vel(HCwindow),'MinPeakProminence',20,'MinPeakWidth',50);
            if ~isempty(hcpeak)
                HC = [HC; lastMSw + hcpeak(find(hcpeakheight == max(hcpeakheight)))];
            else
                HC = [HC; tempstart];
            end
        end
    end
end

% Eliminate gait events that are too close to the beginning/end of the
% trial
HC = HC(HC > 301);
HC = HC(HC < length(MODE_DAQ)-300);
HC = intersect(HC,find(MODE_DAQ > 0));

TO = TO(TO > 301);
TO = TO(TO < length(MODE_DAQ)-300);
TO = intersect(TO,find(MODE_DAQ > 0));

MSw = MSw(MSw > 301);
MSw = MSw(MSw < length(MODE_DAQ)-300);
MSw = intersect(MSw,find(MODE_DAQ > 0));

% Determine the appropriate triggers for each gait event
for i = 1:length(HC)
    prevTO = TO(max(find(TO < HC(i))));
    if ~isempty(prevTO)
        if (HC(i) - prevTO < 1000)
            HC_trig{i,1} = [num2str(MODE_DAQ(prevTO+200)),'3',num2str(MODE_DAQ(HC(i)+200)),'1'];
        else
            HC_trig{i,1} = [num2str(MODE_DAQ(HC(i)-500)),'3',num2str(MODE_DAQ(HC(i)+200)),'1'];
        end
    else % First HC after standing
        HC_trig{i,1} = [num2str(MODE_DAQ(HC(i)-1000)),'3',num2str(MODE_DAQ(HC(i)+200)),'1'];
    end
end

for i = 1:length(TO)
    prevHC = HC(max(find(HC < TO(i))));
    if ~isempty(prevHC)
        if (TO(i) - prevHC < 1000)
            TO_trig{i,1} = [num2str(MODE_DAQ(prevHC+200)),'1',num2str(MODE_DAQ(TO(i)+200)),'2'];
        else
            TO_trig{i,1} = [num2str(MODE_DAQ(TO(i)-500)),'1',num2str(MODE_DAQ(TO(i)+200)),'2'];
        end
    else % First HC after standing
        TO_trig{i,1} = [num2str(MODE_DAQ(TO(i)-1000)),'1',num2str(MODE_DAQ(TO(i)+200)),'2'];
    end
end

for i = 1:length(MSw)
    MSw_trig{i,1} = [num2str(MODE_DAQ(MSw(i)-1000)),'2',num2str(MODE_DAQ(MSw(i)+200)),'3'];
end
end