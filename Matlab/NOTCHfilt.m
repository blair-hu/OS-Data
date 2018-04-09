function filt_data = NOTCHfilt(Fs,N,FcLow,FcHigh,data)

%%%%%%%%%%%%%%%%%%%%%%
%This function high-passfilters the EMG data to reduce the motion artifact
%Fs - sampling frequency
%N - Filter order
%FcLow - vector of lower cutoff frequencies
%FcHigh - vector of upper cutoff frequencies
%data - data to be filtered
%%%%%%%%%%%%%%%%%%%%%%%

temp_data = data;
for notches = 1:length(FcLow)
    [B,A] = butter(N, [FcLow(notches)*2/Fs FcHigh(notches)*2/Fs],'stop');
    for i=1:size(temp_data,2)
        filt_data(:,i) = filtfilt(B,A,temp_data(:,i));
    end
    temp_data = filt_data;
end
filt_data = temp_data;

end