function ageMixing(p,n,k)
p = str2num(p);
n = str2num(n);
k = str2num(k);
if ~isdeployed   
    genpath('/vsc-mounts/leuven-user/305/vsc30534/SimpactWhite')
    path(path,'lib')
    path(path,'MATLAB')
    path(path,'fei/pre_post_process')
    path(path,'lib/events')
    path(path,'lib/statTools')
    path(path,'age_mixing')
end
%%

rng((p + 17)*2213)
[SDS,msg] = modelHIV('new'); 
% global parameters
SDS.start_date = '01-Jan-2008';
SDS.end_date = '01-Dec-2033';
SDS.initial_number_of_females = n;
SDS.initial_number_of_males = n;
SDS.number_of_males = n*1.4; 
SDS.number_of_females = n*1.4;
SDS.number_of_relations = SDS.number_of_males*SDS.number_of_females;
SDS.males.born(1:n) = -ageCast('m',n);
SDS.females.born(1:n) = -ageCast('f',n); 
% parameters of events
% disabled events
SDS.behaviour_change.enable=0;
SDS.male_circumcision.enable=0;
SDS.FSW.enable=0;
SDS.formation_MSM.enable = 0;
SDS.dissolution_MSM.enable = 0;
SDS.ARV_stop.enable = 0;

% formation (baseline)
SDS.formation.baseline_factor = log(8/300);
SDS.formation.current_relations_factor = log(0.7);
SDS.formation.mean_age_factor = log(0.95);
SDS.formation.preferred_age_difference = 6;% adjusted
SDS.formation.age_difference_factor = log(0.85);
SDS.formation.fix_turn_over_rate = 1;
%%%%%%%%%%%
SDS.formation.heterogeneous_age_mixing_behaviour = 0;
SDS.heterogeneous_preferred_age_Cacuchy_scale = 2;
SDS.heterogeneous_preferred_age_Cacuchy_boundary = 40;
SDS.male_heterogeneous_age_factor = log(0.8)/2;
SDS.female_heterogeneous_age_factor = log(0.8)/2;
SDS.heterogeneous_preferred_age_factor = log(0.8);
% age_difference_variation_factor <=log(1) = 0;
SDS.formation.max_difference_male_age = 40;
SDS.formation.male_age_difference_variation_factor = log(1);
SDS.formation.max_difference_female_age = 32;
SDS.formation.female_age_difference_variation_factor = log(1);
% dissolution (baseline)
SDS.dissolution.baseline_factor = log(0.5);
SDS.dissolution.mean_age_factor = log(0.9);
SDS.dissolution.age_difference_factor = log(1.2);
SDS.dissolution.current_relations_factor = 0;
% conception
SDS.conception.baseline_factor = 0.78;
SDS.conception.contraception_effect = -0.5;
SDS.conception.previous_children_factor = -0.2;
SDS.conception.time_factor = 0.95;
SDS.conception.female_age_limit = 50;
% mortality
SDS.non_AIDS_mortality.Weibull_shape_parameter = 3.25;
SDS.non_AIDS_mortality.Weibull_scale_parameter = 62.5;
% introduction
SDS.HIV_introduction.number_of_introduced_HIV = 5;
% transmission
% MTCT
SDS.MTCT_transmission.probability_of_MTCT{2,2}=0.25;
SDS.MTCT_transmission.probability_of_MTCT{3,2}=0.5;
SDS.MTCT_transmission.infectiousness_decreased_by_ARV = 0.9;
SDS.MTCT_transmission.probability_of_breastfeeding = 0.9;
% test
SDS.HIV_test.testing_coverage = 86;
SDS.HIV_test.option_B_coverage = 60;
SDS.HIV_test.monitoring_frequency = 1;
SDS.HIV_test.CD4_baseline_for_ARV;
% ANC
SDS.antenatal_care.attendance;
% ARV (baseline)
SDS.ARV_treatment.ARV_program_start_time = Inf;
% ARV stop (baseline)
% age mixing intervention
SDS.age_mix.intervention_time = '02-Jan-2014';
SDS.age_mix.end_time = '01-Jan-2019';
SDS.age_mix.effect_age_lower_bound = 15;
SDS.age_mix.effect_age_upper_bound = 55;
SDS.age_mix.max_effect_size = 200;
% age mixing intervention stop
SDS.age_mix_stop.enable = 0;
SDS0 = SDS;

% 2008-2013
tic
[SDS0,~]= spRun('start',SDS0); 
t0 = toc;
%%
folder = '/Users/feimeng/SimpactWhite/age_mixing/';
if ~exist(folder,'dir')
folder = '/vsc-mounts/leuven-user/305/vsc30534/SimpactWhite/age_mixing/';
end
SDS_baseline = SDS0;
SDS_baseline.P0.event(6).P.enable = 0;
[SDS_baseline,~]= spRun('restart',SDS_baseline); 
%%
filename = sprintf('%sExposure_%03d_%03d',folder,p,0);
output = exposureTimeByAge(SDS_baseline,20);
save (filename,'-struct','output');
filename = sprintf('%sPrevalence_%03d_%03d',folder,p,0);
output = prevalenceByAge(SDS_baseline,20);
save (filename,'-struct','output');
filename = sprintf('%sRelations_%03d_%03d',folder,p,0);
output = relationsRecord(SDS_baseline);
save (filename,'-struct','output');

pars = parameterGenerator(k);
for r = 1:size(pars,1)
    SDS = SDS0;
    SDS.P0.event(6).P.enable = 1;    
    SDS.P0.event(6).P.baselineChange = pars(r,1);
    SDS.P0.event(6).P.ageDifChange = pars(r,2);
    SDS.P0.event(6).P.ageDifFactorChange = pars(r,3);
    SDS.P0.event(6).P.maxAge = pars(r,4);
    SDS.P0.event(7).P.enable = pars(r,5);
    SDS.P0.event(6).P.end_time = SDS.P0.event(6).P.eventTimes + pars(r,6);
    SDS.P0.event(6).P.male = pars(r,7);
    SDS.P0.event(6).P.all = pars(r,8);
    [SDS,~]= spRun('restart',SDS); 
    filename = sprintf('%sExposure_%03d_%03d',folder,p,r);
    output = exposureTimeByAge(SDS,20);
    save (filename,'-struct','output');
    filename = sprintf('%sPrevalence_%03d_%03d',folder,p,r);
    output = prevalenceByAge(SDS,20);
    save (filename,'-struct','output');
    filename = sprintf('%sRelations_%03d_%03d',folder,p,r);
    output = relationsRecord(SDS);
    save (filename,'-struct','output');
    try
        capture exportCSV(SDS, folder, p, r)
    end
end

end