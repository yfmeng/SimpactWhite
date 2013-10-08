function multipleRun(n)
%
clear all
 %generates a new SDS with all the required stuff
 config = newConfig(n);
 configHeader = num2cell(1:17);
 config = [configHeader
     num2cell(config)];
 
for i=1:n
    
    [SDS,newMSG] = modelHIV('new');
    newSDS=spConfig(SDS,configs(i,:));
    [endSDS, endMSG] = spRun('start',SDS);
    
    results(i,:) = spSummary(endSDS);
    % exportCSV(endSDS)
end
resultsHeader = {}
results = [resultsHeader
    results];
results = [cofig, results];
csvwrite('results.csv',results);
clear all
end
