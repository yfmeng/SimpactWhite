male = [ 0
        8257
        6570
        1704
        1506
        1030
        1754
        2093
        2670
        2346
        1928
        1409
        1151
         817
         971
         698
         891
         635
         613
         895];
female = [0
    7211
        6411
        1593
        1133
        1337
        2477
        2819
        3024
        2081
        1553
        1162
         805
         534
         709
         547
         667
         483
         569
         877];
 all = [0
     15468
       12981
        3297
        2639
        2367
        4231
        4912
        5694
        4427
        3481
        2571
        1956
        1351
        1680
        1245
        1558
        1118
        1182
        1772];
    age = [0,1,5:5:85,100];
    
   %%
    fitted = wblrnd(55,3,1,1000);
    mean(fitted)
    hist(fitted)