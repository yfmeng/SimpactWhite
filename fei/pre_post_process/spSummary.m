function results = spSummary(SDS)

%*****************************************%
% population: average fertility rate, average mortality rate, average population increase
 daysPerYear = spTools('daysPerYear');
 simulationTime = (datenum(SDS.end_date)-datenum(SDS.start_date))/daysPerYear;
 minAge = 15;
 adultFemale = (SDS.females.born<=simulationTime-15);
 adultMale = (SDS.males.born<=simulationTime-15);
femaleLivingTime = sum(min(simulationTime, SDS.females.deceased(adultFemale))...
    -max(SDS.females.born(adultFemale)+minAge,0));
maleLivingTime = sum(min(simulationTime, SDS.males.deceased(adultMale))...
    -max(SDS.males.born(adultMale)+minAge,0));

living = femaleLivingTime + maleLivingTime;

newBorns = sum(SDS.males.born>=0)+sum(SDS.females.born>=0);

deceased = sum(~isnan(SDS.males.deceased))+sum(~isnan(SDS.females.deceased));

aliveMales = [~isnan(SDS.males.born)&isnan(SDS.males.deceased)];
aliveFemales = [~isnan(SDS.females.born)&isnan(SDS.females.deceased)];
aliveEnd = sum(aliveMales)+sum(aliveFemales);

population = [living,newBorns, deceased, aliveEnd];


%*****************************************%
% sexual behaviour: age at first sex (censored?), single time, total number of
% partners, partners/yr, concurrent degree, episode duration
adultMaleNew = SDS.males.born>=-15&SDS.males.born<=(simulationTime-15);
adultFemaleNew = SDS.females.born>=-15&SDS.females.born<=(simulationTime-15);
femaleLivingTime = sum(min(simulationTime, SDS.females.deceased(adultFemaleNew))...
    -max(SDS.females.born(adultFemaleNew)+minAge,0));
maleLivingTime = sum(min(simulationTime, SDS.males.deceased(adultMaleNew))...
    -max(SDS.males.born(adultMaleNew)+minAge,0));

livingNew = femaleLivingTime + maleLivingTime;
% new method to coung adults 
maleActive = unique(SDS.relations.ID(:,1));
maleActive = intersect(maleActive,find(adultMaleNew==1));
femaleActive = unique(SDS.relations.ID(:,2));
femaleActive = intersect(femaleActive,find(adultFemaleNew==1));

% age at first sex
maleFirstSex = inf(1, SDS.number_of_males);
femaleFirstSex = inf(1, SDS.number_of_females);
for ii = 1:length(maleActive)
    i = maleActive(ii);
    maleFirstSex(i) = min(SDS.relations.time(SDS.relations.ID(:,1)==i,1)) - SDS.males.born(i);
end
for ii = 1:length(femaleActive)
    i = femaleActive(ii);
    femaleFirstSex(i) = min(SDS.relations.time(SDS.relations.ID(:,2)==i,1)) - SDS.females.born(i);
end
firstSex = [maleFirstSex,femaleFirstSex];
firstSex = firstSex(~isinf(firstSex));
firstSex = mean(firstSex);
% active time
activeTime = 0;
for i = 1: length(maleActive)
    ii = maleActive(i);
    time = [SDS.relations.time(SDS.relations.ID(:,1)==ii,1),SDS.relations.time(SDS.relations.ID(:,1)==ii,2)];    
    time(isinf(time(:,2)),2) = simulationTime;
    if size(time,1)==1
        activeTime = activeTime + time(:,2)-time(:,1);
    else
        l = length(time(:,1));
          seq = 0:(l-2);
        
        for j = ones(1,l-1).*l- seq
            if time(j,1)<=time(j-1,2)
                time(j-1,2) = time(j,2);
                time(j,:)=[];
            end
        end
        activeTime = activeTime + sum(time(:,2)-time(:,1));
    end
end

for i = 1: length(femaleActive)
    ii = femaleActive(i);
    time = [SDS.relations.time(SDS.relations.ID(:,2)==ii,1),SDS.relations.time(SDS.relations.ID(:,2)==ii,2)];    
    time(isinf(time(:,2)),2) = simulationTime;
    if size(time,1)==1
        activeTime = activeTime + time(:,2)-time(:,1);
    else
        l = length(time(:,1));
          seq = 0:(l-2);
        
        for j = ones(1,l-1).*l- seq
            if time(j,1)<=time(j-1,2)
                time(j-1,2) = time(j,2);
                time(j,:)=[];
            end
        end
        activeTime = activeTime + sum(time(:,2)-time(:,1));
    end
end

% partners
partners =  SDS.relations.ID(ismember(SDS.relations.ID(:,1),maleActive)&ismember(SDS.relations.ID(:,2),femaleActive),:);
partners = unique(partners,'rows');
malePartners = tabulate(double(partners(:,1)));
femalePartners = tabulate(double(partners(:,2)));
malePartners = malePartners(adultMale(1:length(malePartners)),2);
femalePartners = femalePartners(adultFemale(1:length(femalePartners)),2);
partners = [malePartners', femalePartners'];
partners = [mean(partners), median(partners)];
% duration
durations = SDS.relations.time(~isnan(SDS.relations.time(:,1))&~isinf(SDS.relations.time(:,2)), 1:2);
averageDuration = sum(durations(:,2)-durations(:,1))/size(durations,1);

sexWorkers = find(SDS.females.sex_worker);
sexClients = 0;
for i = sexWorkers
    sexClients = sexClients + length(unique(SDS.relations.ID(SDS.relations.ID(:,2)==i,1)));
end

sexuality = [firstSex, activeTime/livingNew, partners, averageDuration, sexClients];

%*****************************************%
% sexual network: density, components, connectiveness...
% connect = ~isnan(SDS.relations.time(:,1))&~isinf(SDS.relations.time(:,2));
% maleID = SDS.relations.ID(connect, 1);
% femaleIDtemp = SDS.relations.ID(connect, 2)+sum(adultMale);
% maleID = double(maleID); 
% femaleIDtemp = double(femaleIDtemp);
% durations = SDS.relations.time(connect,2)-SDS.relations.time(connect,1);
% adults = sum(adultMale)+sum(adultFemale);
% relationMatrix = zeros(adults,adults);
% 
% for i = 1:length(durations)
%     relationMatrix(maleID(i),femaleIDtemp(i)) = 1;
%     %relationMatrix(maleID(i),femaleIDtemp(i)) = relationMatrix(maleID(i),femaleIDtemp(i)) + durations(i);
% end

% density = sum(sum(relationMatrix))/(adults*(adults-1)/2); %?
relations = unique(SDS.relations.ID, 'rows');
relationsNumber = size(relations,1);
totalMale = sum(SDS.males.born<=simulationTime-15);
totalFemale = sum(SDS.females.born<=simulationTime-15);
density = relationsNumber/(totalMale*totalFemale);
network = [density];


%*****************************************%
% HIV: new infections, infectors, total time living with HIV/AIDS (person-yrs), AIDSdeath, no. patients ever started ARV,
% total ARV time (person-yrs) 
total = sum(~isnan([SDS.males.HIV_positive,SDS.females.HIV_positive]));
femaleInfection = sum(SDS.females.HIV_source>0);
maleInfection = sum(SDS.males.HIV_source>0);
infection = femaleInfection+maleInfection;
infector = length(unique(SDS.males.HIV_source))+length(unique(SDS.females.HIV_source));
HIVLiving = max([SDS.males.deceased, SDS.females.deceased],simulationTime)...
    -[SDS.males.HIV_positive, SDS.females.HIV_positive];
HIVLiving = sum(HIVLiving(~isnan(HIVLiving)));
AIDSDeath = sum(SDS.males.AIDS_death) + sum(SDS.females.AIDS_death);
ARVNumber = length(unique(SDS.ARV.ID));
ARVTime = SDS.ARV.time(~isnan(SDS.ARV.time(:,1)),:);
ARVTime(isnan(ARVTime(:,2)),2) = simulationTime;
ARVTime= sum(ARVTime(:,2)-ARVTime(:,1));

HIV = [total infection infector AIDSDeath HIVLiving ARVNumber ARVTime];

%*****************************************%

%*****************************************%

% result  = [population, sexuality, network, HIV];
results = [population, sexuality, network, HIV];
% population = [living,fertility, mortality, aliveEnd];
%sexuality = [firstSex, activeTime, partners, averageDuration, sexClients];
% network = [density];
% HIV = [total infection infector livingWithHIV AIDSDeath HIVLiving ARVNumber ARVTime];


end
