function outputExport(folder)
%%
files = dir();
for i = 1:size(files)
    file = files(i).name;
    if length(file)>=15
        if strcmp(file(1:3),'SDS')&&strcmp(file((length(file)-2):length(file)),'mat')
            % if this file is a sds
            filename = sprintf('%s/%s',folder,file);
            sds = load(filename);
            %
            daysPerYear = (datenum(2000,1,1) - datenum(1900,1,1))/100;
            years = (datenum(sds.end_date) - datenum(sds.start_date))/daysPerYear;
            years = floor(years);
            sds.males.deceased(isnan(sds.males.deceased))=Inf;
            sds.females.deceased(isnan(sds.females.deceased))=Inf;
            sds.males.HIV_positive(isnan(sds.males.HIV_positive))= Inf;
            sds.females.HIV_positive(isnan(sds.females.HIV_positive))= Inf;
            ongoingRelations = [];
            contactTime = [];
            maleExp =[];
            femaleExp =[];
            maleInfection = [];
            femaleInfection = [];
            malePositive = [];
            femalePositive = [];
            maleAlive = [];
            femaleAlive = [];
%             maleExp25 =[];
%             femaleExp25 =[];
%             maleInfection25 = [];
%             femaleInfection25 = [];
%             maleAlive25 = [];
%             femaleAlive25 = [];  
%             malePositive25 = [];
%             femalePositive25 = [];
            % check for each year
            for y = 1:years
                rangeR = sds.relations.time(:,1)<y&sds.relations.time(:,2)>=(y-1);
                ongoingRelations = [ongoingRelations, sum(rangeR)];
                contactTime = [contactTime,sum(min(sds.relations.time(rangeR,2),y)-max(sds.relations.time(rangeR,1),y-1))];
                
                rangeM = sds.males.born<(y-15)&sds.males.born>(y-50)&sds.males.deceased>y;
                rangeF = sds.females.born<(y-15)&sds.females.born>(y-50)&sds.females.deceased>y;
                maleAlive = [maleAlive,sum(rangeM)];
                femaleAlive = [femaleAlive,sum(rangeF)];
                maleInfection = [maleInfection,sum(sds.males.HIV_positive>=(y-1)&sds.males.HIV_positive<=y&rangeM)];
                femaleInfection = [femaleInfection,sum(sds.females.HIV_positive>=(y-1)&sds.females.HIV_positive<=y&rangeF)];
                malePositive = [malePositive,sum(rangeM&sds.males.HIV_positive<y)];
                femalePositive = [femalePositive,sum(rangeF&sds.females.HIV_positive<y)];
%                 
%                 rangeM25 = sds.males.born<(y-15)&sds.males.born>(y-25)&sds.males.deceased>y;
%                 rangeF25 = sds.females.born<(y-15)&sds.females.born>(y-25)&sds.females.deceased>y;
%                 maleAlive25 = [maleAlive25,sum(rangeM25)];
%                 femaleAlive25 = [femaleAlive25,sum(rangeF25)];
%                 maleInfection25 = [maleInfection25,sum(rangeM25&sds.males.HIV_positive>=(y-1)&sds.males.HIV_positive<=y)];
%                 femaleInfection25 = [femaleInfection25,sum(rangeF25&sds.females.HIV_positive>=(y-1)&sds.females.HIV_positive<=y)];
%                 malePositive25 = [malePositive25,sum(rangeM25&sds.males.HIV_positive<y)];
%                 femalePositive25 = [femalePositive25,sum(rangeF25&sds.females.HIV_positive<y)];
%                 
                rangeR = find(rangeR);
                maleID = sds.relations.ID(rangeR,1);
                femaleID = sds.relations.ID(rangeR,2);
                malePos = sds.males.HIV_positive(maleID)';
                femalePos = sds.females.HIV_positive(femaleID)';
                bothPos = malePos<=max(sds.relations.time(rangeR,1),y-1)&femalePos<=max(sds.relations.time(rangeR,1),y-1);
                bothNeg = malePos>min(sds.relations.time(rangeR,2),y)&femalePos>min(sds.relations.time(rangeR,2),y);
                included = find(~bothPos&~bothNeg);
                rangeR = rangeR(included);
                pos1 = min(malePos(included),femalePos(included));
                pos2 = max(malePos(included),femalePos(included));
                maleExpTab = malePos(included)>femalePos(included);
                from = max(max(sds.relations.time(rangeR,1),y-1),pos1);
                to = min(min(sds.relations.time(rangeR,2),y),pos2);
                thisMaleExp = sum(to(maleExpTab)-from(maleExpTab));
                thisFemaleExp = sum(to(~maleExpTab)-from(~maleExpTab));
                maleExp = [maleExp,thisMaleExp];
                femaleExp = [femaleExp,thisFemaleExp];           
            end
            % end years
            output.maleAlive = maleAlive;
            output.malePositive = malePositive;
            output.maleInfection = maleInfection;
            output.maleExp = maleExp;
            
            output.femaleAlive = femaleAlive;
            output.femalePositive = femalePositive;
            output.femaleInfection = femaleInfection;
            output.femaleExp = femaleExp;
            
            file = sprintf('summary_%s',file(5:(length(file)-4)));
            save (file,'-struct','output');
        end
    end
end

end