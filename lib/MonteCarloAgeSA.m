function ages = MonteCarloAgeSA(n,gender,filename)
%%
if strcmp(gender(1),'m')||strcmp(gender,'M')
    col = 1;
else
    col = 2;
end

if ~strcmp(filename(1),'n')
tbl = csvread(filename,1,0);
else
    
tbl = [ 1.0000    2.2000    2.0000
    2.0000    2.1000    2.0000
    3.0000    2.1000    2.0000
    4.0000    2.1000    2.0000
    5.0000    2.1000    2.0000
    6.0000    2.1000    2.0000
    7.0000    2.1000    2.0000
    8.0000    2.1000    2.0000
    9.0000    2.2000    2.1000
   10.0000    2.2000    2.1000
   11.0000    2.2000    2.2000
   12.0000    2.3000    2.2000
   13.0000    2.3000    2.2000
   14.0000    2.3000    2.2000
   15.0000    2.3000    2.2000
   16.0000    2.3000    2.2000
   17.0000    2.4000    2.2000
   18.0000    2.4000    2.2000
   19.0000    2.3000    2.2000
   20.0000    2.2000    2.1000
   21.0000    2.2000    2.0000
   22.0000    2.1000    1.9000
   23.0000    2.0000    1.9000
   24.0000    1.9000    1.8000
   25.0000    1.9000    1.7000
   26.0000    1.8000    1.7000
   27.0000    1.7000    1.6000
   28.0000    1.7000    1.6000
   29.0000    1.6000    1.5000
   30.0000    1.6000    1.5000
   31.0000    1.5000    1.4000
   32.0000    1.5000    1.4000
   33.0000    1.4000    1.4000
   34.0000    1.4000    1.3000
   35.0000    1.3000    1.3000
   36.0000    1.3000    1.3000
   37.0000    1.3000    1.3000
   38.0000    1.2000    1.3000
   39.0000    1.2000    1.2000
   40.0000    1.2000    1.2000
   41.0000    1.2000    1.2000
   42.0000    1.1000    1.2000
   43.0000    1.1000    1.2000
   44.0000    1.1000    1.2000
   45.0000    1.1000    1.2000
   46.0000    1.0000    1.1000
   47.0000    1.0000    1.1000
   48.0000    1.0000    1.1000
   49.0000    0.9000    1.0000
   50.0000    0.9000    1.0000
   51.0000    0.8000    0.9000
   52.0000    0.8000    0.9000
   53.0000    0.8000    0.9000
   54.0000    0.7000    0.8000
   55.0000    0.7000    0.8000
   56.0000    0.7000    0.8000
   57.0000    0.6000    0.7000
   58.0000    0.6000    0.7000
   59.0000    0.6000    0.7000
   60.0000    0.5000    0.6000
   61.0000    0.5000    0.6000
   62.0000    0.5000    0.6000
   63.0000    0.5000    0.6000
   64.0000    0.4000    0.5000
   65.0000    0.4000    0.5000
   66.0000    0.4000    0.5000
   67.0000    0.4000    0.5000
   68.0000    0.3000    0.4000
   69.0000    0.3000    0.4000
   70.0000    0.3000    0.4000
   71.0000    0.3000    0.3000
   72.0000    0.3000    0.3000
   73.0000    0.2000    0.3000
   74.0000    0.2000    0.3000
   75.0000    0.2000    0.3000
   76.0000    0.2000    0.2000
   77.0000    0.2000    0.2000
   78.0000    0.1000    0.2000
   79.0000    0.1000    0.2000
   80.0000    0.1000    0.2000
   81.0000    0.1000    0.1000
   82.0000    0.1000    0.1000
   83.0000    0.1000    0.1000
   84.0000    0.1000    0.1000
   85.0000         0    0.1000
   89.0000    0.1000    0.2000
   94.0000         0    0.1000
   99.0000         0         0
  100.0000         0         0];
end
agesBin = tbl(:,1);
agesBin = [0; agesBin];
cumDistribution = cumsum(tbl(:,col+1));
cumDistribution = [0;cumDistribution]/100;
agesBin = agesBin(diff(cumDistribution)~=0);
cumDistribution = cumDistribution(diff(cumDistribution)~=0);
cumDistribution = cumDistribution/cumDistribution(length(cumDistribution));
randAge = rand(1,n);
ages = interp1(cumDistribution,agesBin,randAge);
end