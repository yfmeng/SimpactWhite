function ageMixingExport(run,scn,folder,t)
%%
for s = 0:scn
    maleID=[];
    femaleID=[];
    maleAge = [];
    femaleAge = [];
    maleTop = 0;
    femaleTop = 0;
    for r = 0:run
        relation = load(sprintf('%sRelations_%03d_%03d.mat',folder,r,s));
        range = relation.time(:,1)<=t&relation.time(:,2)>=t;
        thisMaleID = relation.ID(range,1);
        thisFemaleID = relation.ID(range,2);
        thisMaleAge = relation.age(range,1)+(t-relation.time(range,1));
        thisFemaleAge = relation.age(range,2)+(t-relation.time(range,1));
        
        thisMaleNo = max(thisMaleID);
        maleTop = maleTop+thisMaleNo;
        maleID = [maleID;thisMaleID+maleTop];
        maleAge = [maleAge;thisMaleAge];
        
        thisFemaleNo = max(thisFemaleID);
        femaleTop = femaleTop+thisFemaleNo;
        femaleID = [femaleID;thisFemaleID+femaleTop];
        femaleAge = [femaleAge;thisFemaleAge];
    end
    femaleID = femaleID+max(maleID);
    output = [maleID femaleID maleAge femaleAge];
    names = {'male.id' 'female.id' 'male.age' 'female.age'};
    output = [names 
        num2cell(output)];
    file = sprintf('relation_%03d_%02d',s,t);
    exportCSV_print(fullfile(folder, [file, '.csv']), output);
end
end