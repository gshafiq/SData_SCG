function [ppg_sind,intervals] = f_remove_excess_peaks(sigPPG,ppg_sind,intervals,t)

kk = 1; %counter for remove index
remove_index = [];
for j = 2:length(ppg_sind)
    %if (t(ppg_sind(j))-t(ppg_sind(j-1)) < (median(intervals)-1.5*std(intervals)))
    if (t(ppg_sind(j))-t(ppg_sind(j-1)) < 0.5)
           if (sigPPG(ppg_sind(j))<0.5*sigPPG(ppg_sind(j-1))) %if the jth peak is shorter
               remove_index(kk) = j;
           else
               remove_index(kk) = j-1;
           end
           if kk~=1
               if remove_index(kk) == remove_index(kk-1) %if found duplicate peak
                   remove_index(kk) = []; %remove extra peak
                   kk = kk-1;
               end
           end
           kk = kk+1; %increment counter only if short interval is detected
    end
end
ppg_sind(remove_index) = [];
intervals= diff(t(ppg_sind));



