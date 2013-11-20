death = [SDS.males.deceased,SDS.females.deceased];
born = [SDS.males.born,SDS.females.born];
nohiv = [isnan(SDS.males.HIV_positive),isnan(SDS.females.HIV_positive)];
age = death-born;
age = age(nohiv);
age = age(~isnan(age));
hist(age)
mean(age)
%%
lhs = lhsdesign(1000,2)*10;
file = '/Users/feimeng/Dropbox/Papers_FeiMeng/Age_Mixing/Data/lhs1000by2.csv';
csvwrite(file,lhs)