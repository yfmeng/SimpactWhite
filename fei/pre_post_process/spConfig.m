function SDS = spConfig(SDS, parameterMatrix, k)
% population
% [SDS,newMSG] = modelHIV('new');
SDS.end_date= '31-Dec-1994';
SDS.iteration_limit= 80000;
%SDS.MTCT_transmission.enable = false;
SDS.male_circumcision.enable = false;
SDS.HIV_test.enable= false;
config = parameterMatrix(k,:); % a row from latin hypercube sample

initial = config(1); % round(rand*500+500); % 500 - 1000 individuals per gender per population
SDS.initial_number_of_males =initial;
SDS.number_of_males = round(initial*1.5);
SDS.initial_number_of_females = initial;
SDS.number_of_females = round(initial*1.5);
SDS.number_of_relations = round(initial*2)^2;
SDS.number_of_community_members =config(2);
SDS.sex_worker_proportion = config(3); % 0.5%~8% of the females are involved in transactional sex

% formation
SDS.formation_BCC.baseline_factor =  config(4);
SDS.formation_BCC.current_relations_factor =  config(5);
SDS.formation_BCC.preferred_age_difference =  config(6);
SDS.formation_BCC.community_difference_factor =  config(7);
SDS.formation_BCC.transaction_sex_factor = config(8);
SDS.formation_BCC.last_change_factor = config(9);
% dissolution
SDS.dissolution.baseline_factor = config(10);
SDS.dissolution.current_relations_factor = config(11);
SDS.dissolution.last_change_factor = config(12);
SDS.dissolution.transaction_sex_factor = config(13);
% transmission
SDS.HIV_transmission.infectiousness_decreased_by_ARV= config(14);
SDS.HIV_transmission.sexual_behaviour_parameters{2,1}=config(15);
SDS.HIV_transmission.sexual_behaviour_parameters{2,9}=config(16);

% HIV_test configuration
% changed according to scenario

intervention = false(1, 4);
coverage = [50+rand*50, 0, 0, 0, 0];
newThreshold = Inf;
SDS.HIV_test.treatment_for_population = intervention(1);
SDS.HIV_test.treatment_for_pregnant = intervention(2);
SDS.HIV_test.treatment_for_serodiscordant = intervention(3);
SDS.HIV_test.treatment_for_sex_workers = intervention(4);
SDS.CD4_new_threshold = newThreshold;
SDS.HIV_test.CD4_baseline_for_ARV{2, 2}= coverage(1);
SDS.HIV_test.population_coverage = coverage(2);
SDS.HIV_test.pregnant_coverage = coverage(3);
SDS.HIV_test.serodiscordant_coverage = coverage(4);
SDS.HIV_test.sex_workers_coverage = coverage(5);

% hiv introduction
SDS.HIV_introduction.number_of_introduced_HIV =  config(17);

% MTCT
% breastfeeding = 0.6 + rand*0.3;
% SDS.MTCT.probability_of_breastfeeding = breastfeeding;
% 
% config = [pop, formation, dissolution, transmission, test,introduction];

end