function [pval,pindc,tvec] = f_plot_HR(interval,indc,fs,grph)


pindc = zeros(1,2*length(indc)-1);
pindc(1:2:end) = indc;
pindc(2:2:end-1) = indc(1:end-1)+1;

tvec = pindc/fs;

pval = zeros(1,length(tvec));
pval(1:2:end) = interval;
pval(2:2:end-1) = interval(2:end);

if grph==1
    figure(1112);
plot(tvec,pval)
end




