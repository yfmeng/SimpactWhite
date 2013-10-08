
function TasP_IAS(n,run)
%run = i1 ~ i2; n = number of initial males;

if ~isdeployed
    
    path(path,'lib')
    path(path,'MATLAB')
    path(path,'fei/pre_post_process')
end
 run = str2num(run);
 n  = str2num(n);

 if ~isdir('TasP_IAS')
     mkdir('TasP_IAS');
 end
%%%=======SDS0: year 1998 - 2012===========%%%
%%

rng((run + 17)*2213)
initial = modelHIV('new');
initial.formation.fix_turn_over_rate = 1;
initial.formation.turn_over_rate = 1;

shape = 4.2;
scale = 72;
%shape = 4.3;
%scale = 75;
SDS0 = initial;
SDS0.start_date = '01-Jan-2002';
SDS0.end_date = '01-Jan-2013';
SDS0.initial_number_of_males = n;
SDS0.initial_number_of_females = n;
SDS0.number_of_males = n*1.5;
SDS0.number_of_females = n*1.5;
SDS0.number_of_community_members = floor(SDS0.initial_number_of_males/2); % 4 communities
SDS0.number_of_relations = SDS0.number_of_males*SDS0.number_of_females;
SDS0.HIV_introduction.number_of_introduced_HIV=n*0.15;
SDS0.ARV_treatment.ARV_program_start_time = 0;
SDS0.HIV_transmission.sexual_behaviour_parameters{2,8} = log(1);
SDS0.HIV_transmission.sexual_behaviour_parameters{2,1} = 3;
SDS0.formation.baseline_factor = log(22/n);
SDS0.formation.preferred_age_difference = 4;
SDS0.non_AIDS_mortality.mortality_reference_year = 2002;
SDS0.non_AIDS_mortality.Weibull_shape_parameter = shape;
SDS0.non_AIDS_mortality.Weibull_scale_parameter = scale;
SDS0.formation.current_relations_factor = log(0.1);
maleRange = 1:SDS0.initial_number_of_males;
femaleRange = 1:SDS0.initial_number_of_females;
ageMale = MonteCarloAgeSA(SDS0.initial_number_of_males, 'man',SDS0.age_file);%, '/Simpact/empirical_data/sa_2003.csv');
SDS0.males.born(maleRange) = cast(-ageMale, SDS0.float);    % -years old
ageFemale = MonteCarloAgeSA(SDS0.initial_number_of_females, 'woman',SDS0.age_file);%, '/Simpact/empirical_data/sa_2003.csv');
SDS0.females.born(femaleRange) = cast(-ageFemale, SDS0.float);% -years old
adjust = round(SDS0.initial_number_of_males*0.004);
SDS0.males.born((SDS0.initial_number_of_males+1):(SDS0.initial_number_of_males+adjust)) = -rand(1,adjust)*2;
SDS0.females.born((SDS0.initial_number_of_females+1):(SDS0.initial_number_of_females+adjust)) = -rand(1,adjust)*3;
SDS0 = spRun('start',SDS0);

%%
%=======SDS: year 2014-2034;============%%

% I. access scheme SQ
SDS0.P0.event(17).P.targetCoverage = 0.50;
SDS0.P0.event(17).P.targetCoverageSubpop = 0.50;

% SQ_NON
SDS = SDS0;
SDS = spRun('restart',SDS);
%%
%/vsc-mounts/leuven-user/305/vsc30534/Simpact 
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'SQ','NON');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'SQ_NON');
%%
% SQ.POS
SDS = SDS0;
SDS.P0.event(17).P.criteria(2) = 1;
SDS.P0.event(17).P.CD4baseline(1:2) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'SQ','POS');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'SQ_POS');

% SQ.CD4
SDS = SDS0;
SDS.P0.event(17).P.criteria(2) = 1;
SDS.P0.event(17).P.CD4baseline(1:2) = 500;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'SQ','CD4');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'SQ_CD4');
% SQ.PREG
SDS = SDS0;
SDS.P0.event(17).P.criteria(3) = 1;
SDS.P0.event(17).P.CD4baseline(3) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'SQ','PREG');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'SQ_PREG');
% SQ.SERO ?3 months?
SDS = SDS0;
SDS.P0.event(17).P.criteria(4) = 1;
SDS.P0.event(17).P.CD4baseline(4) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'SQ','SERO3');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'SQ_SERO3');

% SQ.SERO ?1 months?
SDS = SDS0;
SDS.P0.event(17).P.criteria(4) = 1;
SDS.P0.event(17).P.CD4baseline(4) = 5000;
SDS0.P0.event(17).P.longterm_relationship_threshold = 1/12;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'SQ','SERO');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'SQ_SERO1');

% SQ.FSW
SDS = SDS0;
SDS.P0.event(17).P.criteria(5) = 1;
SDS.P0.event(17).P.CD4baseline(5) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'SQ','FSW');
%save(file,'-struct','SDS');
exportCSV(SDS,'',run,'SQ_FSW');

% SQ.MIX
SDS = SDS0;
SDS.P0.event(17).P.criteria(7) = 1;
SDS.P0.event(17).P.CD4baseline(7) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'SQ','MIX');
%save(file,'-struct','SDS');
exportCSV(SDS,'',run,'SQ_MIX');

% SQ.CON
SDS = SDS0;
SDS.P0.event(17).P.criteria(8) = 1;
SDS.P0.event(17).P.CD4baseline(8) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'SQ','CON');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'SQ_CON');


% %% II. access scheme UE1
% SDS0.P0.event(17).P.targetCoverage = 0.50;
% SDS0.P0.event(17).P.targetCoverageSubpop = 0.85;
% SDS0.P0.event(17).P.criteria(2) = 1;
% 
% % UE1.CD4
% SDS = SDS0;
% SDS.P0.event(17).P.criteria(2) = 1;
% SDS.P0.event(17).P.CD4baseline(2) = 5000;
% SDS =spRun('restart',SDS);
% file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE1','CD4');
% %save(file,'-struct','SDS');
% exportCSV(SDS,'',run,'UE1_CD4');
% % UE1.PREG
% SDS = SDS0;
% SDS.P0.event(17).P.criteria(3) = 1;
% SDS.P0.event(17).P.CD4baseline(3) = 5000;
% 
% SDS =spRun('restart',SDS);
% file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE1','PREG');
% %save(file,'-struct','SDS');
% exportCSV(SDS,'',run,'UE1_PREG');
% % UE1.SERO3
% SDS = SDS0;
% SDS.P0.event(17).P.criteria(4) = 1;
% SDS.P0.event(17).P.CD4baseline(4) = 5000;
% 
% SDS =spRun('restart',SDS);
% file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE1','SERO3');
% %save(file,'-struct','SDS');
% exportCSV(SDS,'',run,'UE1_SERO3');
% 
% % UE1.SERO1
% SDS = SDS0;
% SDS.P0.event(17).P.criteria(4) = 1;
% SDS.P0.event(17).P.CD4baseline(4) = 5000;
% 
% SDS0.P0.event(17).P.longterm_relationship_threshold = 1/12;
% SDS =spRun('restart',SDS);
% file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE1','SERO1');
% %save(file,'-struct','SDS');
% exportCSV(SDS,'',run,'UE1_SERO1');
% 
% % UE1.FSW
% SDS = SDS0;
% SDS.P0.event(17).P.criteria(5) = 1;
% SDS.P0.event(17).P.CD4baseline(5) = 5000;
% 
% SDS =spRun('restart',SDS);
% file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE1','FSW');
% %save(file,'-struct','SDS');
% exportCSV(SDS,'',run,'UE1_FSW');
% % UE1.MIX
% SDS = SDS0;
% SDS.P0.event(17).P.criteria(7) = 1;
% SDS.P0.event(17).P.CD4baseline(7) = 5000;
% SDS =spRun('restart',SDS);
% file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE1','MIX');
% %save(file,'-struct','SDS');
% exportCSV(SDS,'',run,'UE1_MIX');
% 
% % UE1.CON
% SDS = SDS0;
% SDS.P0.event(17).P.criteria(8) = 1;
% SDS.P0.event(17).P.CD4baseline(8) = 5000;
% SDS =spRun('restart',SDS);
% file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE1','CON');
% %save(file,'-struct','SDS');
% exportCSV(SDS,'',run,'UE1_CON');


%% III. access scheme UE2
SDS0.P0.event(17).P.targetCoverage = 0.85;
SDS0.P0.event(17).P.targetCoverageSubpop = 0.85;
SDS0.P0.event(17).P.criteria(2) = 1;
% UE2_NON
SDS = SDS0;
SDS = spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE2','NON');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'UE2_NON');
% UE2.POS
SDS = SDS0;
SDS.P0.event(17).P.criteria(1:2) = 1;
SDS.P0.event(17).P.CD4baseline(1:2) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE2','POS');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'UE2_POS');

% UE2.CD4
SDS = SDS0;
SDS.P0.event(17).P.criteria(2) = 1;
SDS.P0.event(17).P.CD4baseline(2) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE2','CD4');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'UE2_CD4');
% UE2.PREG
SDS = SDS0;
SDS.P0.event(17).P.criteria(3) = 1;
SDS.P0.event(17).P.CD4baseline(3) = 5000;

SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE2','PREG');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'UE2_PREG');
% UE2.SERO3
SDS = SDS0;
SDS.P0.event(17).P.criteria(4) = 1;
SDS.P0.event(17).P.CD4baseline(4) = 5000;

SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE2','SERO3');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'UE2_SERO3');

% UE2.SERO1
SDS = SDS0;
SDS.P0.event(17).P.criteria(4) = 1;
SDS.P0.event(17).P.CD4baseline(4) = 5000;

SDS0.P0.event(17).P.longterm_relationship_threshold = 1/12;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE2','SERO1');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'UE2_SERO1');

% UE2.FSW
SDS = SDS0;
SDS.P0.event(17).P.criteria(5) = 1;
SDS.P0.event(17).P.CD4baseline(5) = 5000;

SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE2','FSW');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'UE2_FSW');
% UE2.MIX
SDS = SDS0;
SDS.P0.event(17).P.criteria(7) = 1;
SDS.P0.event(17).P.CD4baseline(7) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE2','MIX');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'UE2_MIX');

% UE2.CON
SDS = SDS0;
SDS.P0.event(17).P.criteria(8) = 1;
SDS.P0.event(17).P.CD4baseline(8) = 5000;
SDS =spRun('restart',SDS);
file = sprintf(' /sds_%04d_%s_%s.mat', run, 'UE2','CON');
%save(file,'-struct','SDS');
exportCSV(SDS,'/vsc-mounts/leuven-user/305/vsc30534/Simpact/TasP_IAS',run,'UE2_CON');
end