%% 
% new SDS
[SDS,msg] = modelHIV('new'); 
% global parameters
SDS.start_date = '01-Jan-1998';
SDS.end_date = '01-Jan-2013';
n = 400;
SDS.initial_number_of_females = n;
SDS.initial_number_of_males = n;
SDS.number_of_males = n*1.2; 
SDS.number_of_females = n*1.2;
SDS.number_of_relations = SDS.number_of_males*SDS.number_of_females;
SDS.males.born(1:n) = -ageCast('male',n);% ageCast need to be contructed
SDS.females.born(1:n) = -ageCast('female',n); 

% parameters of events
% disabled events
SDS.behaviour_change.enable=0;
SDS.male_circumcision.enable=0;
SDS.FSW.enable=0;
SDS.formation_MSM.enable = 0;
SDS.formation.fix_turn_over_rate = 0;
% formation (baseline)
SDS.formation.baseline_factor = log(1.2);
SDS.formation.current_relations_factor = log(0.3);
SDS.formation.age_difference_factor = -log(10)/50;
SDS.formation.mean_age_factor = -log(5)/50;
SDS.formation.preferred_age_difference = 4.5;
% dissolution (baseline)
SDS.dissolution.baseline_factor = log(0.5);
SDS.dissolution.mean_age_factor = 0;
SDS.dissolution.age_difference_factor = 0;
SDS.dissolution.current_relations_factor = 0;
% conception
% introduction
SDS.HIV_introduction.number_of_introduced_HIV = 5;
% transmission
% MTCT
% test
% ARV (baseline)
% ARV stop (baseline)

% stage 1 age mixing intervention strategies X role of intial age mixing patterns
% [mean.age.dif, spread.age.dif, size, gender, length]X[preferred.dif, spread.age.dif, shape]


% stage 2 arv 
% [?]
%
SDS.age_mix.enable = 0;
[SDS1,~]= spRun('start',SDS); 
%%
SDS.age_mix.enable = 1;
SDS.age_mix.age_difference_change = -3;
SDS.age_mix.age_difference_factor_change = 0;
[SDS2,~]= spRun('start',SDS); 
%

SDS.age_mix.enable = 1;
SDS.age_mix.age_difference_change = 0;
SDS.age_mix.age_difference_factor_change = -0.1;
[SDS3,~]= spRun('start',SDS); 
