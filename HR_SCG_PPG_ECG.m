%testing ppg signal peak detection for supine trials
close all; clear all; clc;
%path for annotations
fpath_ann = 'E:\KNU Studies\Research Work\Matlab Codes\SCG annotation\Manual_annotations\Supine_Xi\';
 
trialType = 1; %1-supine, 2-sitting, 3-post exercise
subject =1 ; trial =2;

[filt_acc_full,filt_ecg_full,filt_ppg_full,fs,t_full] = load_trial3(trial,subject);


disc_time = 5*fs;
sigSCG = filt_acc_full(disc_time:end); %prefiltered SCG signal
sigECG = filt_ecg_full(disc_time:end); %prefiltered ECG signal
sigPPG = filt_ppg_full(disc_time:end); %prefiltered PPG signal
t = t_full(disc_time:end);
%% PPG HR detection
thr_ppg = 0.5; grph = 1;
ppg_sind = PTDetect(standarize(sigPPG),thr_ppg);
intervals.ppg = diff(t(ppg_sind));
[ppg_sind,intervals.ppg] = f_remove_excess_peaks(sigPPG,ppg_sind,intervals.ppg,t);
%% ECG HR Detction
thr_ecg = 6; %need to standarize the ECG signal for constant threshold
[rloc,~] = PTDetect(standarize(sigECG),thr_ecg);
intervals.ecg = diff(t(rloc));
ecg_remove = 0;
if length(intervals.ppg)~=length(intervals.ecg) %if there is a mismatch between ecg and ppg peaks
    %order of beats: ECG, SCG then PPG
    if t(ppg_sind(1))<t(rloc(1)) %This is not possible because R peak occurrs first
        ppg_sind(1) = []; %Remove first PPG peak as it is coming from partial cycle
    end
    if t(rloc(end)>t(ppg_sind(end))) % PPG peak
        rloc(end) = []; %Remove last ECG peak as the cycle is not complete
          fprintf('\n\nECG peak removed from end\n')
    end
    
    % Still, if there is extra ECG peak in the begining or extra PPG peak
    % in the end, we need to remove it
    
    if (abs(ppg_sind(1)-rloc(1))>abs(ppg_sind(1)-rloc(2))) %extra first ecg peak
        fprintf('\n\nECG peak removed\n')
        ecg_remove = 1;
        rloc(1) = [];
    end
    
    %remove the last ppg peak till ppg_sind(end)-rloc(end)
    while (abs(ppg_sind(end))-rloc(end)>abs(ppg_sind(end-1)-rloc(end))) %extra last PPG peak, no worries in the comparison
        ppg_sind(end) = [];
    end
    
 %   Even now, if the length Doesn't match, then we check beats one by one
 % w.r.f. ECG R peaks%
    %First peak will be R peak, last peak will be PPG peak
    if length(rloc~=length(ppg_sind))
        for r = 1:length(rloc)
        %looking for extra ppg peaks
        if (ppg_sind(r)-rloc(r)<=0) %ppg peak should always come later
            ppg_sind(r) = []; %remove extra ppg peak
        end
        end
    end


end
intervals.ecg = diff(t(rloc));
intervals.ppg = diff(t(ppg_sind));

figure(5); plot(t,sigPPG,t(ppg_sind),sigPPG(ppg_sind),'m*', t(rloc), sigPPG(rloc),'k^')
title('PPG Peak Detection')
legend('PPG signal','PPG Peak', 'R-peak')
xlabel('Time(s)'); ylabel('Amplitude')
%% SCG HR Detection
load ([fpath_ann 'S' num2str(subject) 'T' num2str(trial)]);
intervals.scg = diff(t(t_AO.tseries));

figure(2); plot(t,sigSCG,t(t_AO.tseries),sigSCG(t_AO.tseries),'r^')
title('Display of AO peaks in SCG signal')
xlabel('Time(s)'); ylabel('Amplitude')

% important points: 
% The first 5 seconds are not annotated for AO peaks
% First and last peaks are discarded, but doesn't affect the time of
% signal.
% 

%% Trial based Comparison plots for intervals
grph = 0; 
[pval.scg,pindc.scg,tvec.scg] = f_plot_HR(intervals.scg,t_AO.tseries(2:end),fs,grph);
[pval.ecg,pindc.ecg,tvec.ecg] = f_plot_HR(intervals.ecg,rloc(2:end),fs,grph);
[pval.ppg,pindc.ppg,tvec.ppg] = f_plot_HR(intervals.ppg,ppg_sind(2:end),fs,grph);


figure(3); plot(tvec.ecg,pval.ecg,tvec.ppg,pval.ppg,tvec.scg,pval.scg)
grid on;
legend('ECG','PPG','SCG')
xlabel('Time(seconds)')
ylabel('Interval (seconds)')
title('Heart Beat Intervals Comparison between ECG, PPG and SCG')

length(intervals.ppg)
length(intervals.ecg)
length(intervals.scg)


