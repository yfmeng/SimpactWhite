%% 
%test results from stergm
[SDS,msg] = modelHIV('new'); 
SDS.start_date = '01-Jan-1998';
SDS.end_date = '31-Dec-2005';
n = 500;
%set parameters of the population
SDS.initial_number_of_females = n;
SDS.initial_number_of_males = n;
SDS.number_of_males = n; 
SDS.number_of_females = n;
SDS.percentage_of_MSM = 1;
SDS.number_of_relations = SDS.number_of_males*SDS.number_of_females;
% etc...
% set parameters of events
% etc...

SDS.AIDS_mortality.enable=0;
SDS.antenatal_care.enable=0;
SDS.ARV_treatment.enable=0;
SDS.ARV_stop.enable=0;
SDS.behaviour_change.enable=0;
%SDS.birth.enable=0;
SDS.male_circumcision.enable=0;
SDS.conception.enable=0;
%SDS.dissolution.enable=0;
SDS.FSW.enable=0;
%SDS.HIV_introduction.enable=0;
SDS.MTCT_transmission.enable=0;
%SDS.non_AIDS_mortality.enable=0;
SDS.HIV_test.enable=0;
%SDS.HIV_transmission.enable=0;
SDS.formation_MSM.enable = 0;
%SDS.age_mix.enable = 0;
SDS.formation.fix_turn_over_rate = 0;

% formation parameters

SDS.formation.baseline_factor = -0.3;
SDS.formation.current_relations_factor = -2;
SDS.formation.age_difference_factor = -0.15;
SDS.formation.mean_age_factor = -1;

SDS.dissolution.baseline_factor = -1;
SDS.dissolution.mean_age_factor = 0;
SDS.dissolution.age_difference_factor = 0.25;
SDS.dissolution.current_relations_factor = -2;

% dissolution parameters

[SDS1,~]= spRun('start',SDS); 
SDS.age_mix.enable = 0;
[SDS2,~]= spRun('start',SDS); 
%
SDS.age_mix.enable = 1;
SDS.age_mix.age_difference_factor_change = 0;
SDS.age_mix.age_difference_change = -3;
[SDS3,~]= spRun('start',SDS);
%%
SDS = SDS1;
range = SDS.relations.ID(:,1)>0;
t1 = SDS.relations.time(range,1);
t2 = SDS.relations.time(range,2);
duration = t2-t1;