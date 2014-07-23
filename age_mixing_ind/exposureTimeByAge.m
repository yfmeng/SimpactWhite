function output =exposureTimeByAge(SDS,t)
SDS.males.deceased(isnan(SDS.males.deceased))=Inf;
SDS.females.deceased(isnan(SDS.females.deceased))=Inf;
SDS.males.HIV_positive(isnan(SDS.males.HIV_positive))=Inf;
SDS.females.HIV_positive(isnan(SDS.females.HIV_positive))=Inf;
SDS.males.born(isnan(SDS.males.born))=Inf; 
SDS.females.born(isnan(SDS.females.born))=Inf;
years = 1:t;
ages= 15:5:50;
output.maleAlive =[];
output.femaleAlive = [];
output.maleExposure =[];
output.femaleExposure = [];
for year = years
    for i = 1:(length(ages)-1)
        %%
        maleAlive = SDS.males.born<=(year-ages(i))&SDS.males.born>(year-ages(i+1))&SDS.males.deceased>year;
        maleEnd = min(SDS.males.deceased,year+1);
        output.maleAlive(year,i)=sum(maleEnd(maleAlive)-year);
        
        femaleAlive = SDS.females.born<=(year-ages(i))&SDS.females.born>(year-ages(i+1))&SDS.females.deceased>year;
        femaleEnd = min(SDS.females.deceased,year+1);
        output.femaleAlive(year,i)=sum(femaleEnd(femaleAlive)-year);
        
        maleAlive = find(maleAlive);
        femaleAlive = find(femaleAlive);
        
        maleRange = ~(SDS.relations.time(:,1)>year|SDS.relations.time(:,2)<=(year+1))...
            &ismember(SDS.relations.ID(:,1),maleAlive);
        endTime = min(SDS.relations.time(maleRange,2),year+1);
        startTime = max(SDS.relations.time(maleRange,1),year);
        output.maleExposure(year,i) = sum(endTime-startTime);
        
        femaleRange = ~(SDS.relations.time(:,1)>year|SDS.relations.time(:,2)<=(year+1))...
            &ismember(SDS.relations.ID(:,2),femaleAlive);
        endTime = min(SDS.relations.time(femaleRange,2),year+1);
        startTime = max(SDS.relations.time(femaleRange,1),year);
        output.femaleExposure(year,i) = sum(endTime-startTime);
    end
end

end