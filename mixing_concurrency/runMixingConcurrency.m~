lhs = lhsdesign(100,2); %
lhs(:,1) = log(lhs(:,1)*2); % degree factor
lhs(:,2) = log(lhs(:,2)*2); % degree difference factor

file = '/Users/feimeng/SimpactWhite/mixing_concurrency/lhs.csv';
csvwrite(file,lhs)
%
n = 300;
for run = 1:100
factor =lhs(run,1);
difFactor =lhs(run,2);

tic
ageMixing_concurrency_sensitive(factor,difFactor,run,n);
toc

end
