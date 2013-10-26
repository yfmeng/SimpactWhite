% generate age distribution files
function distributionGenerator(shape,run)
randAge = wblrnd(60,shape,1,10000);
man = zeros(1,100);

for i = 1:100
    man(i) = sum(randAge<=i&randAge>(i-1));
end
man = man/length(randAge)*100;
woman =man;
bin = 1:100;
ages = [bin' man' woman'];
ages = ages(8:end,:);
names = {'age' 'man' 'woman'};
ages = [names
    num2cell(ages)];
shape=num2str(shape);
filename = sprintf('/Users/feimeng/SimpactWhite/empirical_data/agefile_%s.csv',num2str(run));

fid = fopen(filename, 'w', 'n', 'UTF-8');
            fprintf(fid, '%s', ages{1, 1});
            fprintf(fid, ', %s', ages{1, 2:end});
            fprintf(fid, '\n');
            for ii = 2 : size(ages, 1)
                fprintf(fid, '%g', ages{ii, 1});
                fprintf(fid, ', %g', ages{ii, 2:end});
                fprintf(fid, '\n');
            end
status = fclose(fid);
end