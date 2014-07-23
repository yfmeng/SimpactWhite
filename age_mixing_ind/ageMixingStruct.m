function ageMixingStruct(r)
%%
r = str2num(r);% id. runs
n = 500;% no. individuals
if ~isdeployed
    genpath('/vsc-mounts/leuven-user/305/vsc30534/SimpactWhite')
    addpath( [fileparts(fileparts(fileparts(which(mfilename)))) '/lib'] );
    addpath( [fileparts(fileparts(fileparts(which(mfilename)))) '/lib/events'] );
    addpath( [fileparts(fileparts(fileparts(which(mfilename)))) '/lib/statTools'] );
    addpath( [fileparts(fileparts(fileparts(which(mfilename)))) '/age_mixing'] );
end

folder = '/Users/feimeng/SimpactWhite/age_mixing_ind/';
if ~exist(folder,'dir')
    folder = '/vsc-mounts/leuven-user/305/vsc30534/SimpactWhite/age_mixing/';
end
%
parameters = ageMixingStructParameters;
j= r;
for i = 1:size(parameters,1)
    rng((r + 17)*2213)
    [SDS,msg] = modelHIV('new');
    % global parameters
    SDS.start_date = '01-Jan-1998';
    SDS.end_date = '02-Jan-2014';
    SDS.initial_number_of_females = n;
    SDS.initial_number_of_males = n;
    SDS.number_of_males = n;
    SDS.number_of_females = n;
    SDS.number_of_relations = SDS.number_of_males*SDS.number_of_females;
    % ******* Age structure variables ********
    SDS.age_struct.read_from_table = false;
    SDS.percentage_of_MSM =0;
    % parameters of events
    % disabled events
    SDS.behaviour_change.enable=0;
    SDS.male_circumcision.enable=0;
    SDS.FSW.enable=0;
    SDS.formation_MSM.enable = 0;
    SDS.dissolution_MSM.enable = 0;
    SDS.ARV_stop.enable = 0;
    
    % formation (baseline)
    SDS.formation.current_relations_factor = log(0.1);
    SDS.formation.fix_turn_over_rate = 1;
    SDS.formation.turn_over_rate = 0.08;
    % age_difference_variation_factor <=log(1) = 0;
    SDS.formation.max_difference_male_age = 40;
    SDS.formation.male_age_difference_variation_factor = log(1);
    SDS.formation.max_difference_female_age = 32;
    SDS.formation.female_age_difference_variation_factor = log(1);
    
    SDS.formation.heterogeneous_age_mixing_behaviour = 1;
    SDS.formation.heterogeneous_preferred_age_Cacuchy_shape = 5;
    SDS.formation.formation.heterogeneous_preferred_age_Cacuchy_boundary = 60;
    SDS.formation.male_heterogeneous_age_factor = log(0.8);
    SDS.formation.female_heterogeneous_age_factor = log(0.8);
    SDS.formation.heterogeneous_preferred_age_factor = -5;
    
    % dissolution (baseline)
    SDS.dissolution.baseline_factor = log(0.5);
    SDS.dissolution.mean_age_factor = log(0.9);
    SDS.dissolution.age_difference_factor = log(1.2);
    SDS.dissolution.current_relations_factor = 0;
    % conception
    SDS.conception.baseline_factor = 0.8;
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
    SDS.MTCT_transmission.enable = 0;
    % test
    %SDS.HIV_test.enable = 0;
    % ARV (baseline)
    %SDS.ARV_treatment.enable = 0;
    % ARV stop (baseline)
    SDS.ARV_stop.enable = 0;
    % age mixing intervention
    SDS.age_mix.enable = 0;
    % age mixing intervention stop
    SDS.age_mix_stop.enable = 0;
    SDS0 = SDS;
    %%%%%%%%%%%%%%%%%%%%%
    SDS0.formation.mean_age_factor = log(parameters(i,1));
    SDS0.formation.preferred_age_difference = parameters(i,2);% adjusted
    SDS0.formation.age_difference_factor = log(parameters(i,3));
    SDS0.formation.male_heterogeneous_age_factor = log(parameters(i,3))/2;
    SDS0.formation.female_heterogeneous_age_factor = log(parameters(i,3))/2;
    SDS0.formation.baseline_factor = log(parameters(i,4));
    SDS.age_struct.scale = parameters(i,5);
    SDS.age_struct.shape = parameters(i,6);
    SDS.risky_sex.baseline = parameters(i,7);
    SDS.risky_sex.female_age_factor = log(parameters(i,8));
    SDS.risky_sex.mean_age_factor = log(parameters(i,9));
    SDS.risky_sex.age_difference_factor = log(parameters(i,10));
    SDS.males.born(1:SDS.initial_number_of_males) = -ageCast('m',SDS.initial_number_of_males,SDS.age_struct.scale,SDS.age_struct.shape);
    SDS.females.born(1:SDS.initial_number_of_females) = -ageCast('f',SDS.initial_number_of_females,SDS.age_struct.scale,SDS.age_struct.shape);
    SDS0 = SDS;
    [SDS0,~]= spRun('start',SDS0);
    %%
    filename = sprintf('%sSDS_%03d_%03d.mat',folder,i,j);
    if isfield(SDS0,'P0')
        SDS0 = rmfield(SDS0,'P0');
    end
    save(filename,'-struct','SDS0');
    filename = sprintf('%sExposureStr_%03d_%03d',folder,i,j);
    output = exposureTimeByAge(SDS0,15);
    save (filename,'-struct','output');
    filename = sprintf('%sPrevalenceStr_%03d_%03d',folder,i,j);
    output = prevalenceByAge(SDS0,15);
    save (filename,'-struct','output');
    filename = sprintf('%sRelationsStr_%03d_%03d',folder,i,j);
    output = relationsRecord(SDS0);
    save (filename,'-struct','output');
%     %% hetero
%     SDS0 = SDS;
%     SDS0.formation.heterogeneous_age_mixing_behaviour = 1;
%     SDS0.formation.baseline_factor = log(parameters(i,4)+0.25);
%     [SDS0,~]= spRun('start',SDS0);
%     filename = sprintf('%sSDS_%03d_%03d_hetero.mat',folder,i,j);
%     if isfield(SDS0,'P0')
%         SDS0 = rmfield(SDS0,'P0');
%     end
%     save(filename,'-struct','SDS0');
%     filename = sprintf('%sExposureStr_%03d_%03d_hetero',folder,i,j);
%     output = exposureTimeByAge(SDS0,15);
%     save (filename,'-struct','output');
%     filename = sprintf('%sPrevalenceStr_%03d_%03d_hetero',folder,i,j);
%     output = prevalenceByAge(SDS0,15);
%     save (filename,'-struct','output');
%     filename = sprintf('%sRelationsStr_%03d_%03d_hetero',folder,i,j);
%     output = relationsRecord(SDS0);
%     save (filename,'-struct','output');
end
end