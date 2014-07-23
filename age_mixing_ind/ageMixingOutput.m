function [male,female,summary] = ageMixingOutput(run,scn,folder,t,t0)
%%
maleAlive = struct();
maleInfection = struct();
maleExposure = struct();
malePositive = struct();
femaleAlive = struct();
femaleInfection = struct();
femaleExposure = struct();
femalePositive = struct();
summary.maleInfection = [];
summary.maleExposure = [];
summary.femaleInfection = [];
summary.femaleExposure = [];
zeroMat = zeros(t-t0+1,7);
for s = 0:scn
    % sum up all runs
    scenario = sprintf('scn_%03d',s);
    maleAlive = setfield(maleAlive,scenario,zeroMat);
    maleInfection = setfield(maleInfection,scenario,zeroMat);
    maleExposure = setfield(maleExposure,scenario,zeroMat);
    malePositive = setfield(malePositive,scenario,zeroMat);
    femaleAlive = setfield(femaleAlive,scenario,zeroMat);
    femaleInfection = setfield(femaleInfection,scenario,zeroMat);
    femaleExposure = setfield(femaleExposure,scenario,zeroMat);
    femalePositive = setfield(femalePositive,scenario,zeroMat);    
    for r = 0:run
        prevalence = load(sprintf('%sPrevalence_%03d_%03d.mat',folder,r,s));
        exposure = load(sprintf('%sExposure_%03d_%03d.mat',folder,r,s));
        maleAlive.(scenario) = maleAlive.(scenario)+prevalence.malePopulation(t0:t,:);
        maleInfection.(scenario)=maleInfection.(scenario)+prevalence.maleInfection(t0:t,:);
        malePositive.(scenario)=malePositive.(scenario)+prevalence.maleInfection(t0:t,:);
        maleExposure.(scenario)=maleExposure.(scenario)+exposure.maleExposure(t0:t,:);
        femaleAlive.(scenario) = femaleAlive.(scenario)+prevalence.femalePopulation(t0:t,:);
        femaleInfection.(scenario)=femaleInfection.(scenario)+prevalence.femaleInfection(t0:t,:);
        femalePositive.(scenario)=femalePositive.(scenario)+prevalence.femaleInfection(t0:t,:);
        femaleExposure.(scenario)=femaleExposure.(scenario)+exposure.femaleExposure(t0:t,:);
    end
    
    summary.maleInfection = [summary.maleInfection,sum(sum(maleInfection.(scenario)))];
    summary.maleExposure = [summary.maleExposure,sum(sum(maleExposure.(scenario)))];    
    summary.femaleInfection = [summary.femaleInfection,sum(sum(femaleInfection.(scenario)))];
    summary.femaleExposure = [summary.femaleExposure,sum(sum(femaleExposure.(scenario)))];
    
%      maleAlive.(scenario) = num2cell(maleAlive.(scenario));
%      maleInfection.(scenario) = num2cell(maleInfection.(scenario));
%      malePositive.(scenario) = num2cell(malePositive.(scenario));
%      maleExposure.(scenario) = num2cell(maleExposure.(scenario));
%      
%      femaleAlive.(scenario) = num2cell(femaleAlive.(scenario));
%      femaleInfection.(scenario) = num2cell(femaleInfection.(scenario));
%      femalePositive.(scenario) = num2cell(femalePositive.(scenario));
%      femaleExposure.(scenario) = num2cell(femaleExposure.(scenario));
end

male.alive = maleAlive;
male.infection=maleInfection;
male.positive = malePositive;
male.exposure = maleExposure;

female.alive = femaleAlive;
female.infection=femaleInfection;
female.positive = femalePositive;
female.exposure = femaleExposure;
% write summary
summaryOutput = [num2cell(summary.maleExposure') num2cell(summary.femaleExposure') num2cell(summary.maleInfection') num2cell(summary.femaleInfection')];
pars = [zeros(1,8);parameterGenerator(4)];
pars = num2cell(pars);
parnames ={'p1' 'p2' 'p3' 'p4' 'p5' 'p6' 'p7' 'p8'};
pars = [parnames
    pars];
summaryNames = {'maleExposure' 'femaleExposure' 'maleInfection' 'femaleInfection'};
summaryOutput = [summaryNames
    summaryOutput];
summaryOutput = [pars summaryOutput];
file = sprintf('summary_%02d_%02d',t0,t);
exportCSV_print(fullfile(folder, [file, '.csv']), summaryOutput);
% write separate scenarios
ageBinName = {'age15','age20','age25','age30','age35','age40','age45'};
varName = summaryNames;
names = {};
for i = 1:length(varName)
    for j = 1:length(ageBinName)
        names = [names sprintf('%s_%s',varName{i},ageBinName{j})];
    end
end
summary.maleInfection = [];
summary.femaleInfection = [];
summary.maleExposure = [];
summary.femaleExposure = [];
for s = 0:scn
    scenario = sprintf('scn_%03d',s);
    this.maleInfection = maleInfection.(scenario);
    this.maleInfection = sum(this.maleInfection);
    summary.maleInfection = [summary.maleInfection; this.maleInfection];
    this.femaleInfection = femaleInfection.(scenario);
    this.femaleInfection = sum(this.femaleInfection);
    summary.femaleInfection = [summary.femaleInfection; this.femaleInfection];
    
    this.maleExposure = maleExposure.(scenario);
    this.maleExposure = sum(this.maleExposure);
    summary.maleExposure = [summary.maleExposure; this.maleExposure];
    this.femaleExposure = femaleExposure.(scenario);
    this.femaleExposure = sum(this.femaleExposure);
    summary.femaleExposure = [summary.femaleExposure; this.femaleExposure];    
end

summaryOutput = [names
    num2cell(summary.maleExposure) num2cell(summary.femaleExposure) num2cell(summary.maleInfection) num2cell(summary.femaleInfection)];
summaryOutput = [pars summaryOutput];
file = sprintf('summary_by_age_%02d_%02d',t0,t);
exportCSV_print(fullfile(folder, [file, '.csv']), summaryOutput);
end
