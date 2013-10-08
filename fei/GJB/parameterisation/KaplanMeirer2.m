PRand = spTools('handle','rand0toInf');
eventTime = spTools('handle','expLinear');
r = PRand(1,1000);
alpha = -log(1);
beta = log(0.75);
t = eventTime(alpha, beta, 0, r);
t = t*52;
sum(isinf(t))
mean(t(~isinf(t)))
hist(t(~isinf(t)),1000)

range = 1:480;
n = zeros(1,480); 
d = zeros(1,480); 
p = zeros(1,480); 
s = ones(1,480); 
i = 1;
n(i) = sum(t>i-1);
d(i) = sum(t>i-1&t<=i);
p(i) = (n(i)-d(i))/n(i);

for i =range(2:480)
    n(i) = sum(t>i-1);
    d(i) = sum(t>i-1&t<=i);
    p(i) = (n(i)-d(i))/n(i);
    s(i) = s(i-1)*p(i);
end

plot(range,s)