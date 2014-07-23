function parameterMat =  parameterGeneratorStruct
% n = number of trials
% parameter 1~3
baslineChange = 1-(0.1:0.1:0.5);
baselineChange =log(baslineChange)';%5
preferredAgeDifChange = -(1:8)';%8
ageDifFactorChange = 1-(0.1:0.1:0.5);
ageDifFactorChange = log(ageDifFactorChange)';%5

end 