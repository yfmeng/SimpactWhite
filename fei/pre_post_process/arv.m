sds = load('sds_0001_SQ_G3');
% demographicgraphs(sds);
mean(sds.ARV.CD4(sds.ARV.ID>0))
t = 1:40;
born = [sds.males.born,sds.females.born];
pos = [sds.males.HIV_positive, sds.females.HIV_positive];
die = [sds.males.deceased,sds.females.deceased];

post = [];
arvt = [];
for i =t
  alive = born<=i&(isnan(die)|die>i);
  p = pos<i&alive;
  post=[post, sum(p)/sum(alive)];
  a = 0;
  for j = 1:sum(sds.ARV.ID>0)
      if sds.ARV.time(j,1)<i&&alive(sds.ARV.ID(j))
          a = a+1;
      end
  end
  arvt = [arvt, a/sum(p)];
    
end
plot(arvt)