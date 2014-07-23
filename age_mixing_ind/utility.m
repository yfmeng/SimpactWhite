%%
folder = './age_mixing_ind'
files = dir(folder);
%%

for i = 1:length(files)
    %
    display(i)
    file = files(i).name;
    if length(file)>=15
        if strcmp(file(1:3),'SDS')&&strcmp(file((length(file)-2):(length(file))),'mat')
            if ~strcmp(file((length(file)-9):(length(file)-4)),'hetero')
                sds = load(file);
                born.born= [sds.males.born,sds.females.born];
                born.dead= [sds.males.deceased,sds.females.deceased];
                filename = sprintf('Born_%s.mat',file(5:11));
                save(filename,'-struct','born');
            end
            if strcmp(file((length(file)-9):(length(file)-4)),'hetero')
                sds = load(file);
                born.born= [sds.males.born,sds.females.born];
                born.dead= [sds.males.deceased,sds.females.deceased];
                filename = sprintf('Born_%s_hetero.mat',file(5:11));
                save(filename,'-struct','born');
            end
        end
    end
    
end

