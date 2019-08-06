% Getting Heart beat intervals from ECG, PPG and SCG for supine trials
% Aug 6, 2019
% PPG available for subjects 1-6 in supine position

% This code is divided in two sections: i) ECG/PPG comparison and ii)
% ECG/SCG comparison

close all; clear all; clc
fpath_ann = 'Manual Annotations\Supine_Xi\';

substr.trials1 = 1:3;
substr.trials2 = 1:3;
substr.trials3 = [2 4];
substr.trials4 = 1:3;
substr.trials5 = 1:3;
substr.trials6 =1:3;
substr.trials7 =1:2;
subjects = 1:7;
Nsub = length(subjects);

% Results Variable Declarations
Combined_Int.ECG = []; %for 7 subjects
Combined_Int.SCG = []; %for 7 subjects
Combined_Int.PPG = []; %for 6 subjects
Marker_indicator.ECG = []; %beat starting index for subject 7 (which can be excluded from ECG-PPG analysis)
Marker_indicator.SCG = [];
% Main loop for iterations
 for i = 1:Nsub %
    Trials = eval(['substr.trials' num2str(i)]);
    for j = 1:length(Trials) %
            if subjects(i)~=7
              [filt_acc_full,filt_ecg_full,filt_ppg_full,fs,t_full] = load_trial3(Trials(j),subjects(i));
              disc_time = 5*fs;
              sigSCG = filt_acc_full(disc_time:end); %prefiltered SCG signal
              sigECG = filt_ecg_full(disc_time:end); %prefiltered ECG signal
              sigPPG = filt_ppg_full(disc_time:end); %prefiltered PPG signal
            else
              disc_time = 5*fs;
             [filt_acc_full,filt_ecg_full,fs,t_full] = load_trial185_3(Trials(j),subjects(i));
            sigSCG = filt_acc_full(disc_time:end); %prefiltered SCG signal
            sigECG = filt_ecg_full(disc_time:end); %prefiltered ECG signal
            end
           
            
            t = t_full(disc_time:end);
            %% ECG HR Detction
            thr_ecg = 6; %need to standarize the ECG signal for constant threshold
            [rloc,~] = PTDetect(standarize(sigECG),thr_ecg);
            intervals.ecg = diff(t(rloc));
            if (subjects(i)==6 && Trials(j) == 3)
                Marker_indicator.ECG = length(Combined_Int.ECG); %set marker at final trial of subject 6
            end
            Combined_Int.ECG = [Combined_Int.ECG intervals.ecg(2:end-1)]; %combined intervals in seconds
            numpeaks_ecg(i,j) = length(intervals.ecg)-2;
            %Since SCG first and last peak annotations are skipped for
            %to ensure complete cycle, First and Last Peaks in ECG and PPG
            %will be skipped similarly
            %% SCG HR Detection
            load ([fpath_ann 'S' num2str(subjects(i)) 'T' num2str(Trials(j))]);
            intervals.scg = diff(t(t_AO.tseries));
            if (subjects(i)==6 && Trials(j) == 3)
                Marker_indicator.SCG = length(Combined_Int.SCG); %set marker at final trial of subject 6
            end
            Combined_Int.SCG = [Combined_Int.SCG intervals.scg];
            numpeaks_scg(i,j) = length(intervals.scg);
            %% PPG HR Detection
            if subjects(i)==7
                %Do nothing
                continue
            else %Detect PPG
                  R_last_removed = 0;
                thr_ppg = 0.5; grph = 1;
                ppg_sind = PTDetect(standarize(sigPPG),thr_ppg);
                intervals.ppg = diff(t(ppg_sind));
                [ppg_sind,intervals.ppg] = f_remove_excess_peaks(sigPPG,ppg_sind,intervals.ppg,t);
                if length(intervals.ppg)~=length(intervals.ecg) %if there is a mismatch between ecg and ppg peaks
                    %order of beats: ECG, SCG then PPG
                    if t(ppg_sind(1))<t(rloc(1)) %This is not possible because R peak occurrs first
                        ppg_sind(1) = []; %Remove first PPG peak as it is coming from partial cycle
                    end
                    if t(rloc(end)>t(ppg_sind(end))) % PPG peak
                        rloc(end) = []; %Remove last ECG peak as the cycle is not complete
                        %this is the only R peak that is removed
                        R_last_removed = 1;
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
                clear  intervals.ppg;
                 intervals.ppg = diff(t(ppg_sind));
                Combined_Int.PPG = [Combined_Int.PPG intervals.ppg(2:end-1)];
                numpeaks_ppg(i,j) = length(intervals.ppg)-2;
                if R_last_removed==1
                    Combined_Int.ECG(end) = []; %Removing last ECG peak if cycle incomplete
                    Combined_Int.SCG(end) = []; %Removing last SCG peak if cycle incomplete
                end
            end 
    end
 end

 %% Plotting the Analysis
 figure(889); %BA Plots
 subplot(211); title('SCG and ECG Intervals')
 [mn_diff.SCG_ECG CI.SCG_ECG dval.SCG_ECG sval.SCG_ECG] = g_BAplot(Combined_Int.SCG,Combined_Int.ECG,t,1)
 xlabel('(x_1+x_2)/2 (s)'); ylabel('x_1-x_2 (s)')
 subplot(212); title('PPG and ECG Intervals')
 [mn_diff.PPG_ECG CI.PPG_ECG dval.PPG_ECG sval.PPG_ECG] = g_BAplot(Combined_Int.PPG,Combined_Int.ECG(1:length(Combined_Int.PPG)),t,1)
 xlabel('(x_1+x_2)/2 (s)'); ylabel('x_1-x_2 (s)')
 
 
dCI.SCG_ECG = CI.SCG_ECG(2)-CI.SCG_ECG(1)
dCI.PPG_ECG = CI.PPG_ECG(2)-CI.PPG_ECG(1)


figure(890); %Bar plot for showing confidence intervals
 bar([dCI.SCG_ECG*1000, dCI.PPG_ECG*1000])
 xticklabels({'SCG-ECG','PPG-ECG'})
 ylabel('CI (milliseconds)')