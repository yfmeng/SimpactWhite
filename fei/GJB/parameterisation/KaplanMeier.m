P = spTools('rand0toInf', 1, 100);
t = spTools('expLinear',1.2,-5,0,P);
t = t*52;

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
