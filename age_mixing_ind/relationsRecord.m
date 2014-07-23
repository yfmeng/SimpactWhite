function output = relationsRecord(SDS)
 output = SDS.relations;
 output = rmfield(output,'type');
 output = rmfield(output,'condom_use');
 output = rmfield(output,'proximity');
 output.time(isnan(output.time(:,2)),2) = Inf;
 range = output.ID(:,1)>0;
 output.ID = output.ID(range,:);
 output.time = output.time(range,:);
 output.age = [];
 for i = 1:size(output.ID,1)
     output.age(i,1) = output.time(i,1)-SDS.males.born(output.ID(i,1));
     output.age(i,2) = output.time(i,1)-SDS.females.born(output.ID(i,2));
 end
end