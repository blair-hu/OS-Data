subjMVC_RMS = cell(10,14);
subj = {'AB156','AB185','AB186','AB188','AB189','AB190','AB191','AB192','AB193','AB194'};
header = {'RTA' 'RMG' 'RSOL' 'RBF' 'RST' 'RVL' 'RRF' 'LTA' 'LMG' 'LSOL' 'LBF' 'LST' 'LVL' 'LRF'};
for i = 1:10
    mvc_data = csvread([subj{i},'_MVC.csv']);
    for j = 1:14
        mvc_data_use = mvc_data(find(~isnan(mvc_data(:,j))),j);
        
        close all        
        plot(mvc_data_use)
        hold on;    
        subjMVC_RMS{i,j} = RMSfilter(mvc_data_use,200,199,1)';
        plot(subjMVC_RMS{i,j})
        
        prompt = {'Enter truncate:','Enter start:','Enter finish'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'','',''};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
       
        subjMVC_max(i,j) = mean(subjMVC_RMS{i,j}(str2num(answer{2}):str2num(answer{3})));
        
        if length(answer{1}) > 0
            mvc_data_save{j} = mvc_data_use(1:str2num(answer{1}));
        else
            mvc_data_save{j} = mvc_data_use;
        end
        
        mvc_length(j) = length(mvc_data_save{j});
    end
    mvc_save = nan(max(mvc_length),14);
    for j = 1:14
       mvc_save(1:mvc_length(j),j) = mvc_data_save{j}; 
    end
    T_MVC = array2table(mvc_save,'VariableNames',header);
    writetable(T_MVC,[subjID{i},'_MVC_trunc.csv','Delimiter',',']
end
save('AllSubjMVC.mat','subjMVC_max');