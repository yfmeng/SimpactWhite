ps = ['0','1','2','3','4','5','6','7','8','9'];

for i =5:8
    ageMixing(ps(i),'400','4')
    folder = '/Users/feimeng/SimpactWhite/age_mixing/';
    ageMixingOutput(i-1,16,folder,11,6)
    ageMixingOutput(i-1,16,folder,16,6)
    ageMixingOutput(i-1,16,folder,20,6)
end
%%
sds = SDS_baseline;
range = sds.relations.ID(:,1)>0;
t0 = sds.relations.time(range,1);
mage = t0-sds.males.born(sds.relations.ID(range,1))';
fage = t0-sds.females.born(sds.relations.ID(range,2))';
scatter(fage,mage)
%% 
        for t = 6:20
            ageMixingExport(7,16,folder,t)
        end