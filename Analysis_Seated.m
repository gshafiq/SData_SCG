% Getting Heart beat intervals from ECG, PPG and SCG for seated trials
% August 6, 2019
% PPG not available for seated trials

% Only ECG and SCG comparisons are made in this program

close all; clear all; clc
fpath_ann = 'Manual Annotations\Sitting_Xi\';

subjects = [2 6 7];
substr.trials1 = 1:3;
substr.trials2 = 1:3;
substr.trials3 = 1:3;
Nsub = length(subjects);

% Results Variable Declarations
Combined_Int.ECG = []; %for 3 subjects
Combined_Int.SCG = []; %for 3 subjects
% Main loop for iterations
 for i = 1:Nsub %
    Trials = eval(['substr.trials' num2str(i)]);
    for j = 1:length(Trials) %
          
              [filt_acc_full,filt_ecg_full,fs,t_full] = load_trial3_sit(Trials(j),subjects(i));
              disc_time = 5*fs;
              sigSCG = filt_acc_full(disc_time:end); %prefiltered SCG signal
              sigECG = filt_ecg_full(disc_time:end); %prefiltered ECG signal
              t = t_full(disc_time:end);
            %% ECG HR Detction
            thr_ecg = 6; %need to standarize the ECG signal for constant threshold
            [rloc,~] = PTDetect(standarize(sigECG),thr_ecg);
            intervals.ecg = diff(t(rloc));
            Combined_Int.ECG = [Combined_Int.ECG intervals.ecg(2:end-1)]; %combined intervals in seconds
            numpeaks_ecg(i,j) = length(intervals.ecg)-2;
            %Since SCG first and last peak annotations are skipped for
            %to ensure complete cycle, First and Last Peaks in ECG and PPG
            %will be skipped similarly
            %% SCG HR Detection
            load ([fpath_ann 'S' num2str(subjects(i)) 'T' num2str(Trials(j))]);
            intervals.scg = diff(t(t_AO.tseries));
            Combined_Int.SCG = [Combined_Int.SCG intervals.scg];
            numpeaks_scg(i,j) = length(intervals.scg);
          
    end
 end

 %% Plotting the Analysis
 figure(889);%BA Plot
 [mn_diff.SCG_ECG CI.SCG_ECG dval.SCG_ECG sval.SCG_ECG] = g_BAplot(Combined_Int.SCG,Combined_Int.ECG,t,1)
 xlabel('(x_1+x_2)/2 (s)'); ylabel('x_1-x_2 (s)')
 
 dCI.SCG_ECG = CI.SCG_ECG(2)-CI.SCG_ECG(1)
 figure(890);
 bar([dCI.SCG_ECG]*1000);
  xticklabels({'SCG-ECG'})
 ylabel('CI (milliseconds)')
