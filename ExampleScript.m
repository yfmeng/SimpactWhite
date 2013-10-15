
% (1)
% add the current folder to MatLab Path
% generates a new SDS (Simpact Data Structure)
addpath(genpath('/Simpact'))

[SDS,msg] = modelHIV('new'); 

% (2)
%set parameters of the population
SDS.initial_number_of_females = 50;
SDS.initial_number_of_males = 50;
SDS.number_of_males = 100; 
SDS.number_of_females = 100;

SDS.number_of_relations = SDS.number_of_males*SDS.number_of_females;
% etc...
% set parameters of events
SDS.formation.baseline_factor = log(0.5);
SDS.formation.current_relations_factor = 0;
% etc...

% disable  events
SDS.formation.enable=1;
SDS.debut.enable=1;

% SDS.AIDS_mortality.enable=0;
% SDS.antenatal_care.enable=0;
% SDS.ARV_treatment.enable=0;
% SDS.ARV_stop.enable=0;
% SDS.behaviour_change.enable=0;
% SDS.birth.enable=0;
% SDS.male_circumcision.enable=0;
% SDS.conception.enable=0;
% SDS.dissolution.enable=0;
% SDS.FSW.enable=0;
% SDS.HIV_introduction.enable=0;
% SDS.MTCT_transmission.enable=0;
% SDS.non_AIDS_mortality.enable=0;
% SDS.HIV_test.enable=0;
% SDS.HIV_transmission.enable=0;
% (3)
% actually run the model
[SDS, ~] = spRun('start',SDS); 

% % (4)
% % export result as .csv files
% % or generate graphs from the
% exportCSV(SDS,'Simpact',1,'example');
% concurrencyPrevalence(SDS);
% demographicGraphs(SDS);


