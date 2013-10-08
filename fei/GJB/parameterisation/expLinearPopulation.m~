prand = spTools('handle','rand0toInf');
pexpLinear = spTools('handle','expLinear');
n  = 100:200:2000;
meanmin = [];
meanmin1 = [];
meanmin2 = [];
meanmin3 = [];
alpha = -log(30);
beta = -0.2;
for i  = 1:length(n)
    mintime = [];
    for j = 1:n(i)
        rands = prand(1, n(i));
        times = pexpLinear(alpha, beta, 0, rands);
        mintime = [mintime min(times)];
        times1 = pexpLinear(alpha/log(n(i)), beta, 0, rands);
        mintime1 = [mintime1 min(times1)];
        times2 = pexpLinear(alpha/n(i), beta, 0, rands);
        mintime2 = [mintime2 min(times2)];
        times3 = pexpLinear(alpha/exp(n(i)), beta, 0, rands);
        mintime3 = [mintime3 min(times3)];
    end
    meanmin = [meanmin, mean(mintime)];
    meanmin1 = [meanmin1 mean(mintime1)];
    meanmin2 = [meanmin2 mean(mintime2)];
    meanmin3 = [meanmin3 mean(mintime3)];
end

plot(n,meanmin1,n,meanmin2,n,meanmin3)

