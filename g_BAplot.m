function [mean_diff CI diff_val sum_val] = g_BAplot(x,y,t,grph)
% Function for BA analysis and plot
%grph = 1 for plotting the graphs
% Dated: 17/03/2018
% y should be the reference signal
diff_val = y-x;
sum_val = (y+x)/2;

std_diff = std(diff_val);
mean_diff = mean(diff_val);

CI = [mean_diff-(1.96*std_diff) mean_diff+(1.96*std_diff)];

plot(sum_val, diff_val, 'x');
hold on;

plot([min(sum_val) max(sum_val)], [CI(1) CI(1)],'color',[0,0.45,0.74]); plot([min(sum_val) max(sum_val)], [CI(2) CI(2)],'color',[0,0.45,0.74])
axis('tight')

