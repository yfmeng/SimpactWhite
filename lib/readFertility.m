function fertility = readFertility(filename)
if strcmp(filename(1),'n')
 fertility = [     
    2000    0.2300
    2005    0.2200
    2007    0.2120
    2008    0.2070
    2009    0.2040
    2010    0.2020
    2011    0.2010
    2012    0.2010
    2012    0.2000
    2022    0.1950];
else
 fertility = csvread(filename,1,0)/10;
end
end