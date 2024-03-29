function [P,T] = PTDetect(x,E)
%x is the input signal
%E is threshold
%P is the peaks
%T is the troughts
P = []; T= []; a = 1; b = 1; i = 0; d = 0;
xL = length(x);
while (i~=xL)
    i = i+1;
    if (d==0)
        if (x(a)>=(x(i)+E))
            d = 2;
        elseif(x(i)>=(x(b)+E))
            d =1;
        end
        if(x(a)<=x(i))
            a = i;
        elseif (x(i)<=x(b))
            b = i;
        end
    elseif (d==1)
        if (x(a)<=x(i))
            a = i;
        elseif(x(a)>=(x(i)+E))
            P = [P a]; b = i; d = 2;
        end
    elseif (d==2)
        if (x(i)<=x(b))
            b = i;
        elseif(x(i)>=(x(b)+E))
            T = [T b]; a = i; d = 1;
        end
    end
end
