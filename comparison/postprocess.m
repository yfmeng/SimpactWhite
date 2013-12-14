
%%
runs = 1:10;
output_formation = [runs' times' formations'];
csvwrite('/Users/feimeng/SimpactWhite/comparison/run_time_formation.csv',output_formation)
%%
mean(times)
mean(formations)
std(times)
std(formations)
%%
n = [];
events = [];
for i = 1:10
filename = sprintf('sds_duration_%d.mat',i)
sds=load(filename);
n = [n sum(sds.relations.ID(:,1)>0)];
ei = sum(sds.relations.ID(:,1)>0&isfinite(sds.relations.time(:,2)));
events = [events ei+sum(sds.relations.ID(:,1)>0)];
end
mean(n)
std(n)
mean(events)
std(events)
%%
time = [962 900 917 907];
formations =[];
events =[];
durations =[];
ages = [];
for i = 1:4
filename=sprintf('%s/sds_test_%d.mat',pwd,i);
sds=load(filename);
formations = [formations sum(sds.relations.ID(:,1)>0)];
eventi = formations(i)...
    +sum(sds.relations.ID(:,1)>0&isfinite(sds.relations.time(:,2)))...
    +sum(~isnan(sds.males.deceased))+sum(~isnan(sds.females.deceased));
events = [events eventi];

agei = [sds.males.deceased, sds.females.deceased]-[sds.males.born,sds.females.born];
ages = [ages agei];
durationi = sds.relations.time(:,2)-sds.relations.time(:,1);
durationi = durationi(~isnan(durationi)&isfinite(durationi))';
durations = [durations durationi];
end
%%
mean(time)
std(time)
%%
mean(formations)
std(formations)
%%
mean(events)
std(events)
%%
mean(durations)
std(durations)
%%
fitdist(ages','Weibull')
%
randAge = wblrnd(70,4,1,1000000);
randAge = randAge(randAge>=30);
hist(randAge)
%
age = 30:ceil(max(max(ages),max(randAge)));
simpact=[];
randWeibull=[];
for i =1:(length(age)-1)
    simpact(i)=sum(ages>=age(i)&ages<age(i+1))/length(ages);
    randWeibull(i)=sum(randAge>=age(i)&randAge<age(i+1))/length(randAge);
end
output = [age(2:end)' simpact' randWeibull'];
%
csvwrite('/Users/feimeng/SimpactWhite/comparison/age_at_death_new.csv',output)
%csvwrite('/Users/feimeng/SimpactWhite/comparison/run_time_death.csv',times)

