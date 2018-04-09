function filt_data = LPfilt(Fs,N,Fc,data)

%%%%%%%%%%%%%%%%%%%%%%
%This function high-passfilters the EMG data to reduce the motion artifact
%Fs - sampling frequency
%N - Filter order
%Fc - cutoff frequency
%data - data to be filtered
%%%%%%%%%%%%%%%%%%%%%%%

[B,A] = butter(N, Fc/(Fs/2), 'low');

for i=1:size(data,2)
    filt_data(:,i) = filtfilt(B,A,data(:,i));
end