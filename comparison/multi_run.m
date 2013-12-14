function multi_run(r)
if ~isdeployed
    path(path,'lib')
    path(path,'MATLAB')
    path(path,'fei/pre_post_process')
end

r = str2num(r);
% open a text file for output
folder = '/vsc-mounts/leuven-user/305/vsc30534/SimpactWhite';
filename = sprintf('%s/output_%d.text',folder,r);
results =[];
%results = [n, t, no.events, no.formation, duration];
for n = [200,500,1000,1500,2000,2500,3000]
    % run
    [SDS,t]=single_run(r,n);
    
    nf = sum(SDS.relations.ID(:,1)>0);
    ne = nf...
        +sum(SDS.relations.ID(:,1)>0&isfinite(SDS.relations.time(:,2)))...
        +sum(~isnan(SDS.males.deceased))+sum(~isnan(SDS.females.deceased));
    SDS.relations.time(~isfinite(SDS.relations.time(:,2)),2) = 15;
    du = SDS.relations.time(:,2)-SDS.relations.time(:,1);
    du = mean(du(~isnan(du)));
    output = [n,t,ne,nf,du];
    results = [results; 
               output];
    % write: n, t, no.events, no.formation, duration
    myformat = '%5d %5d %5d %5d %f\n';
    fid = fopen(filename,'w');
    fprintf(fid, myformat, results');
    fclose(fid);
end

end