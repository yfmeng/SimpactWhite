function output = prevalenceByAge(SDS,t)
SDS.males.deceased(isnan(SDS.males.deceased))=Inf;
SDS.females.deceased(isnan(SDS.females.deceased))=Inf;
SDS.males.HIV_positive(isnan(SDS.males.HIV_positive))=Inf;
SDS.females.HIV_positive(isnan(SDS.females.HIV_positive))=Inf;
SDS.males.born(isnan(SDS.males.born))=Inf; 
SDS.females.born(isnan(SDS.females.born))=Inf;
years = 1:t;
output.malePopulation = [];
output.femalePopulation = [];
output.totalPopulation=[];
output.malePositive = [];
output.femalePositive = [];
output.totalPositive = [];
output.maleInfection = [];
output.femaleInfection = [];
ageBin = 15:5:50;
for year = years
    maleAge = year-SDS.males.born;
    femaleAge = year - SDS.females.born;
    maleAge(isnan(maleAge))=Inf;
    femaleAge(isnan(femaleAge))=Inf;
    for i = 1:(length(ageBin)-1)
        output.malePopulation(year,i) = sum(maleAge>=ageBin(i)&maleAge<=ageBin(i+1)&SDS.males.deceased>(year+1));
        output.malePositive(year,i) =  sum(maleAge>=ageBin(i)&maleAge<=ageBin(i+1)&SDS.males.deceased>(year+1)&SDS.males.HIV_positive<=(year+1));
        output.maleInfection(year,i) =  sum(maleAge>=ageBin(i)&maleAge<=ageBin(i+1)&SDS.males.deceased>(year+1)&SDS.males.HIV_positive<=(year+1)&SDS.males.HIV_positive>year);

        output.femalePopulation(year,i) = sum(femaleAge>=ageBin(i)&femaleAge<=ageBin(i+1)&SDS.females.deceased>(year+1));
        output.femalePositive(year,i) =  sum(femaleAge>=ageBin(i)&femaleAge<=ageBin(i+1)&SDS.females.deceased>(year+1)&SDS.females.HIV_positive<=(year+1));
        output.femaleInfection(year,i) =  sum(femaleAge>=ageBin(i)&femaleAge<=ageBin(i+1)&SDS.females.deceased>(year+1)&SDS.females.HIV_positive<=(year+1)&SDS.females.HIV_positive>year);
    end
end
output.totalPopulation = output.malePopulation+output.femalePopulation;
output.totalPositive = output.malePositive+output.femalePositive;
output.totalInfection = output.maleInfection+output.femaleInfection;
end