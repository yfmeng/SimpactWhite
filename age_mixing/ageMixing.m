%% 
% new SDS
[SDS,msg] = modelHIV('new'); 
% global parameters
SDS.start_date = '01-Jan-2008';
SDS.end_date = '01-Jan-2028';
n = 500;
SDS.initial_number_of_females = n;
SDS.initial_number_of_males = n;
SDS.number_of_males = round(n*1.2); 
SDS.number_of_females = round(n*1.2);
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
SDS.formation.baseline_factor = -0.3;
SDS.formation.current_relations_factor = -2;
SDS.formation.age_difference_factor = -0.15;
SDS.formation.mean_age_factor = -1;
% dissolution (baseline)
SDS.dissolution.baseline_factor = -1;
SDS.dissolution.mean_age_factor = 0;
SDS.dissolution.age_difference_factor = 0.25;
SDS.dissolution.current_relations_factor = -2;
% conception
% introduction
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