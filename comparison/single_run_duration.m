
function times = single_run_duration
times = [];
shape = 4;
scale = 70;
for run = 4:4
rng((run + 17)*2213)
SDS = modelHIV('new');
n = 200;
SDS.start_date = '01-Jan-1980';
SDS.end_date = '01-Jan-2100';
SDS.initial_number_of_males = n;
SDS.initial_number_of_females = n;
SDS.number_of_males = n;
SDS.number_of_females = n;
SDS.number_of_relations = SDS.number_of_males*SDS.number_of_females;
SDS.FSW.enable = 0;
SDS.behaviour_change.enable = 0;
SDS.formationMSM.enable = 0;
SDS.HIV_test.enable = 0;
SDS.non_AIDS_mortaltiy.enable = 0;
SDS.AIDS_mortality.enable = 0;
SDS.conception.enable = 0;
SDS.birth.enable = 0;
SDS.HIV_introduction.enable = 0;
SDS.HIV_transmission.enable = 0;
SDS.conception.enable = 0;
SDS.birth.enable = 0;
SDS.circumcision.enable = 0;
SDS.debut.enable=1;
SDS.formation.enable=1;
SDS.dissolution.enable = 1;
SDS.non_AIDS_mortality.enable = 1;
SDS.non_AIDS_mortality.Weibull_shape_parameter= 4;
SDS.non_AIDS_mortality.Weibull_scale_parameter= 70;
SDS.formation.baseline_factor = log(10/200);
SDS.dissolution.baseline_factor = log(0.5);

maleRange = 1:SDS.initial_number_of_males;
femaleRange = 1:SDS.initial_number_of_females;
SDS.age_file = 'none'; 
ageMale = 30*ones(1,SDS.number_of_males);
SDS.males.born(maleRange) = cast(-ageMale, SDS.float);    % -years old
ageFemale = 30*ones(1,SDS.number_of_males);
SDS.females.born(femaleRange) = cast(-ageFemale, SDS.float);% -years old
%
tic
SDS = spRun('start',SDS);
SDS = rmfield(SDS,'P0');
t = toc;
filename=sprintf('%s/sds_test_%d.mat',pwd,run);
save(filename,'-struct','SDS')
times = [times,t];
end
times
end