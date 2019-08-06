function [filt_acc,filt_ecg,fs,t] = load_trial185_3(trial,subject)
fpath_n = 'E:\KNU Studies\Research Work\Data sets\Accelerometer_and_Vicon\Combined\Symm_Config\';
load ([fpath_n 's0' num2str(subject) '_t0' num2str(trial)]);
axis = 3; % 1-x,2-y,3-z.
fs = 500;
fs_ecg = 500;
sig_ecg = ecg_mp;
offset = 54e-3*fs;
signal_acc = accel(1*axis,:); %accel 1, axis 3
t_n = 0:1/fs:185-1/fs;
% Filtering the signal
fc_acc = 2*[1 35]/fs;
fc_ecg = 2*[1 45]/fs_ecg;
order = 5;
[bac,aac] = butter(order,fc_acc,'bandpass');
[becg,aecg] = butter(order,fc_ecg,'bandpass');
filt_ecgs = filtfilt(becg,aecg,sig_ecg);
filt_acc_nsp = filtfilt(bac,aac,signal_acc')';
filt_accs = spline(t_dsp,filt_acc_nsp,t_n);
filt_acc = filt_accs(offset:end);
filt_ecg = filt_ecgs(1:end-offset+1);
t = 0:1/fs:(length(filt_acc)-1)/fs;

% figure(9909); plot(t_dsp,filt_acc_nsp,t_n,filt_accs,'m');
% legend('Original','spline')