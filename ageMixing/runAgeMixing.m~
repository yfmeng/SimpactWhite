lhs = lhsdesign(20,3); %
lhs(:,1) = lhs(:,1)*10-3; % preferred age
lhs(:,2) = log(lhs(:,2)+0.5); % age factor
lhs(:,3) = lhs(:,3)*5; % Weibull shape

n = 300;

file = '/Users/feimeng/SimpactWhite/ageMixing/lhs2140.csv';
csvwrite(file,lhs)
%
for run = 21:40
agedif=lhs(run-20,1);
factor =lhs(run-20,2);
shape=lhs(run-20,3);
tic
distributionGenerator(shape,run);
ageMixing(agedif,factor,shape,run,n);
toc

end

% 
