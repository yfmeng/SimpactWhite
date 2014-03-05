expLinear = spTools('handle', 'expLinear');
intExpLinear = spTools('handle', 'intExpLinear');
P = rand(1,10000);
P = exp(P);
a= -rand(1,10000)*3;
b = ones(1,10000)*-0.1;
t0 = expLinear(a,b,0,P);
%
now = 1;
fired = t0<now;
t0(fired)=Inf;
Pc = intExpLinear(a,b,0,1);
P = P-Pc;
P(fired) = exp(rand(1,sum(fired)));
t0 = t0-1;
%
next = 2;
fired = t0<(next-now);
t0(fired)=Inf;
P(fired) = Inf;
Pc = intExpLinear(a,b,1,2);
sum(Pc>P)