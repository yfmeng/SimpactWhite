function [configs, results] = multipleRun(i, folder)
% run SIMPACT n times with same scenario and different parameter sets 
% calling modelHIV, spConfig, spRun, spSummary, exportCSV
addpath( [fileparts(fileparts(fileparts(which(mfilename)))) '/lib'] );

if (isdeployed)
    i = str2num(i)
else
    addpath( [fileparts(fileparts(fileparts(which(mfilename)))) '/lib'] );
end

rng((i + 17)*2213)

file=sprintf('%04d', i);
[SDS,newMSG] = modelHIV('new'); 
% generate a new SDS 
SDS =spConfig(SDS,parameterMatrix,i); 
% configeration: parameters are generated from certain distribution
[SDS, endMSG] = spRun('start',SDS); 
% run 

% get the summary of simulation results
% csvwrite(fullfile(folder, ['results_', file, '.csv']), spSummary(SDS));

exportCSV(SDS, folder, i) 
%export csv files for each run if necessary

end
