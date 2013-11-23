
function SDS = ageMixing(agedif,factor,shape,run,n)
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
scale = 70;
SDS0.start_date = '01-Jan-1986';
SDS0.end_date = '01-Jan-1999';
SDS0.initial_number_of_males = n;
SDS0.initial_number_of_females = n;
SDS0.number_of_males = n;
SDS0.number_of_females = n;
SDS0.percentage_of_MSM = 5;
SDS0.number_of_community_members = floor(SDS0.initial_number_of_males/2); % 4 communities
SDS0.number_of_relations = SDS0.number_of_males*SDS0.number_of_females;
SDS0.HIV_introduction.number_of_introduced_HIV=5;
%SDS0.HIV_introduction.enable =0;
SDS0.ARV_treatment.enable = 0;
SDS0.HIV_transmission.sexual_behaviour_parameters{2,8} = log(1);
SDS0.HIV_transmission.sexual_behaviour_parameters{2,1} = 3;
SDS0.formation.baseline_factor = log(10/n);
SDS0.FSW.enable = 0;
SDS0.behaviour_change.enable = 0;
SDS0.formationMSM.enable = 0;
SDS0.HIV_test.enable = 0;
%SDS0.non_AIDS_mortaltiy.enable = 0;
SDS0.AIDS_mortality.enable = 0;
%SDS0.dissolution.enable = 0;
SDS0.conception.enable = 0;
SDS0.non_AIDS_mortality.mortality_reference_year = 2002;
SDS0.non_AIDS_mortality.Weibull_shape_parameter = shape;
SDS0.non_AIDS_mortality.Weibull_scale_parameter = scale;
SDS0.formation.current_relations_factor = log(0.5);
maleRange = 1:SDS0.initial_number_of_males;
femaleRange = 1:SDS0.initial_number_of_females;
SDS0.age_file = 'none'; 
ageMale = empiricalAge(SDS0.initial_number_of_males, 'man',SDS0.age_file);
 SDS0.males.born(maleRange) = cast(-ageMale, SDS0.float);    % -years old
 ageFemale = empiricalAge(SDS0.initial_number_of_females, 'woman',SDS0.age_file);
 SDS0.females.born(femaleRange) = cast(-ageFemale, SDS0.float);% -years old
SDS0.count1=0;
SDS0.count2=0;
SDS0.record = [];
SDS0.record2 = [];
SDS0.formation.preferred_age_difference = agedif;
SDS0.formation.age_difference_factor = factor;
SDS0 = spRun('start',SDS0);
SDS0 = rmfield(SDS0,'P0');
file = sprintf('sds_%s','test');
%exportCSV(SDS0,'/Users/feimeng/SimpactWhite/ageMixing',run,file);
toc
SDS = SDS0;
end