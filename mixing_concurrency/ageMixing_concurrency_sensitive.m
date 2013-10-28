
function ageMixing_concurrency_sensitive(factor,difFactor,run,n)
%run = i1 ~ i2; n = number of initial males;

% if ~isdeployed
%     
%     path(path,'lib')
%     path(path,'MATLAB')
%     path(path,'fei/pre_post_process')
% end
%  run = str2num(run);
%  n  = str2num(n);

%  if ~isdir('ageMixing')
%      mkdir('ageMixing');
%  end
%%
tic
rng((run + 17)*2213)
SDS0 = modelHIV('new');
scale = 65;
shape = 4.3;
SDS0.start_date = '01-Jan-2002';
SDS0.end_date = '01-Jan-2005';
SDS0.initial_number_of_males = n;
SDS0.initial_number_of_females = n;
SDS0.number_of_males = n;
SDS0.number_of_females = n;
SDS0.number_of_community_members = floor(SDS0.initial_number_of_males/2); % 4 communities
SDS0.number_of_relations = SDS0.number_of_males*SDS0.number_of_females;
SDS0.HIV_introduction.number_of_introduced_HIV=round(n*0.01);
SDS0.ARV_treatment.enable = 0;
SDS0.HIV_transmission.sexual_behaviour_parameters{2,8} = log(1);
SDS0.HIV_transmission.sexual_behaviour_parameters{2,1} = 3;
SDS0.formation.baseline_factor = log(4/n);
SDS0.FSW.enable = 0;
SDS0.formationMSM.enable = 0;
SDS0.HIV_test.enable = 0;
SDS0.non_AIDS_mortaltiy.enable = 0;
SDS0.AIDS_mortality.enable = 0;
SDS0.conception.enable = 0;

SDS0.non_AIDS_mortality.mortality_reference_year = 2002;
SDS0.non_AIDS_mortality.Weibull_shape_parameter = shape;
SDS0.non_AIDS_mortality.Weibull_scale_parameter = scale;
maleRange = 1:SDS0.initial_number_of_males;
femaleRange = 1:SDS0.initial_number_of_females;
SDS0.age_file = 'none';
ageMale = MonteCarloAgeSA(SDS0.initial_number_of_males, 'man',SDS0.age_file);%, '/Simpact/empirical_data/sa_2003.csv');
ageFemale = MonteCarloAgeSA(SDS0.initial_number_of_females, 'woman',SDS0.age_file);%, '/Simpact/empirical_data/sa_2003.csv');
SDS0.males.born(maleRange) = cast(-ageMale, SDS0.float);    % -years old
SDS0.females.born(femaleRange) = cast(-ageFemale, SDS0.float);% -years old

SDS0.formation.current_relations_factor=factor;
SDS0.formation.current_relations_difference_factor=difFactor;
SDS0.formation.baseline_factor = SDS0.formation.baseline_factor - SDS0.formation.current_relations_factor ...
    - SDS0.formation.current_relations_difference_factor; % temporary

SDS0.formation.fix_turn_over_rate = true;
SDS0.formation.warm_up_period = 0.5;

SDS0 = spRun('start',SDS0);
SDS0 = rmfield(SDS0,'P0');
file = sprintf('sds_%s','test');
exportCSV(SDS0,'/Users/feimeng/SimpactWhite/mixing_concurrency',run,file);
toc
end