function [filt_acc,filt_ecg,filt_ppg,fs,t] = load_trial3(trial,subject)
fpath_n = 'Supine\';
load ([fpath_n 's0' num2str(subject) '_t0' num2str(trial)]);

axis = 3; % 1-x,2-y,3-z.

fs = 500;
fs_ecg = length(ecgRaw)/180;
if fs_ecg == 1000
    sig_ecg = downsample(ecgRaw,2);
    sig_ppg = downsample(ppgRaw,2);
    fs_ecg = 500;
    
else
    sig_ecg = ecgRaw;
    sig_ppg = ppgRaw;
end
offset = 54e-3*fs;
signal_acc = accel(1*axis,:); %accel 1, axis 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_n = 0:1/fs:180-1/fs;
% Filtering the signal
fc_acc = 2*[1 35]/fs; %%%%%%%%%%%warning: changed from 30Hz
fc_ecg = 2*[1 45]/fs_ecg;
fc_ppg = 2*[1 10]/fs_ecg;
order = 4;
[bac,aac] = butter(order,fc_acc,'bandpass');
[becg,aecg] = butter(order,fc_ecg,'bandpass');
[bppg,appg] = butter(order,fc_ppg,'bandpass');
filt_ecgs = filtfilt(becg,aecg,sig_ecg);
filt_ppg = filtfilt(bppg,appg,sig_ppg);
filt_acc_nsp = filtfilt(bac,aac,signal_acc')';
filt_accs = spline(t_dsp,filt_acc_nsp,t_n);
filt_acc = filt_accs(offset:end);
filt_ecg = filt_ecgs(1:end-offset+1);
filt_ppg = filt_ppg(1:end-offset+1);
t = 0:1/fs:(length(filt_acc)-1)/fs;

% figure(9909); plot(t_dsp,filt_acc_nsp,t_n,filt_accs,'m');
% legend('Original','spline')
