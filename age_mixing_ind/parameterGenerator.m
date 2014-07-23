function parameterMat =  parameterGenerator(k)
% n = number of trials
% parameter 1~3

baselineChange = [0 log(0.75), log(0.5)]';%1-2
preferredAgeDifChange = [0 -2, -4, -6]';%3-5
ageDifFactorChange = [0 log(0.95), log(0.9) log(0.85) log(0.8)]';%6-9
% parameter 4~8
effectAgeLevel = [22, 25]';%a
effectDieOut = [0,1]';%b
recruitTime = [3,10]';%c
effectMales = [0,1]';%d
effectSizeLevel = [0,1]';%e
% total number of scenarios = 9*16 = 192; estimate: 35 hrs

generators = fracfactgen('a b c d e f g h i j k l m n',k);
[df,confounding] = fracfact(generators);
df(df == -1) = 0;
x11 = df(:,1);x12 = df(:,2)*2;
x1 = max(x11,x12);
x21 = df(:,3);x22 = df(:,4)*2;x23 = df(:,5)*3;
x2 = max(max(x21,x22),x23);
x31 = df(:,6);x32 = df(:,7)*2;x33 = df(:,8)*3;x34=df(:,9)*4;
x3 = max(max(x31,x32),max(x33,x34));
df = [x1 x2 x3 df(:,10:14)];
df = df+1;

parameterMat = zeros(size(df));
parameterMat(:,1) = baselineChange(df(:,1));
parameterMat(:,2) = preferredAgeDifChange(df(:,2));
parameterMat(:,3) = ageDifFactorChange(df(:,3));
parameterMat(:,4) = effectAgeLevel(df(:,4));
parameterMat(:,5) = effectDieOut(df(:,5));
parameterMat(:,6) = recruitTime(df(:,6));
parameterMat(:,7) = effectMales(df(:,7));
parameterMat(:,8) = effectSizeLevel(df(:,8));
end 

%%

