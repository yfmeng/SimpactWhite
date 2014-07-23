
% (1)
% add the current folder to MatLab Path
% generates a new SDS (Simpact Data Structure)
addpath(genpath('/SimpactWhite'))
%%

[SDS,msg] = modelHIV('new'); 
%%
SDS.start_date = '01-Jan-1998';
SDS.end_date = '31-Dec-2028';
% (2)
n = 150;
%set parameters of the population
SDS.initial_number_of_females = n;
SDS.initial_number_of_males = n;
SDS.number_of_males = 2*n; 
SDS.number_of_females = 2*n;
SDS.percentage_of_MSM = 1;
SDS.number_of_relations = SDS.number_of_males*SDS.number_of_females;
% etc...
% set parameters of events
SDS.formation.baseline_factor = log(0.05);
SDS.formation.current_relations_factor = 0;
% etc...

% disable  events

%SDS.AIDS_mortality.enable=0;
SDS.antenatal_care.enable=0;
SDS.ARV_treatment.enable=0;
SDS.ARV_stop.enable=0;
SDS.behaviour_change.enable=0;
%SDS.birth.enable=0;
SDS.male_circumcision.enable=0;
%SDS.conception.enable=0;
%SDS.dissolution.enable=0;
SDS.FSW.enable=0;
SDS.HIV_introduction.enable=0;
SDS.MTCT_transmission.enable=0;
%SDS.non_AIDS_mortality.enable=0;
SDS.HIV_test.enable=0;
%SDS.HIV_transmission.enable=0;
SDS.formation_MSM.enable = 0;
SDS.age_mix.enable = 0;
SDS.formation.fix_turn_over_rate = 1;


[SDS,~]= spRun('start',SDS); 
%%
% % (4)
% % export result as .csv files
% % or generate graphs from the
% exportCSV(SDS,'Simpact',1,'example');
%

