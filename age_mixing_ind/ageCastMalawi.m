function output = ageCastMalawi(gender,n)
%% data from 2008 survey: southern, rural MALAWI
age = [0:98,100];
male = [0
       95947
       87631
       86672
       90250
       91623
       84900
       74457
       78361
       78469
       61250
       70749
       58538
       68712
       57633
       59998
       55424
       45223
       39560
       46939
       34647
       40795
       33960
       38211
       34492
       35488
       43713
       33729
       31196
       43460
       28041
       43459
       23585
       29661
       25722
       20796
       32576
       23260
       19509
       25834
       14866
       26422
        9653
       14259
       11629
       14633
       16206
       10414
        8832
       15263
        8519
       16797
        6699
        8831
        6343
        7113
        9835
        9938
        6694
       13103
       10611
       11766
        6124
        6078
        6428
        4593
        6695
        5583
        3865
        7832
        4733
        6639
        2929
        4067
        3202
        2557
        4532
        4921
        2830
        5339
        2452
        3569
        1854
        1949
        1370
        1227
        1434
        2550
        1287
        2264
         758
        1364
         368
         444
         863
         810
         547
         336
         426
        500];
female = [0
       100396
       90486
       90079
       93747
       94399
       86741
       76833
       79938
       81196
       62947
       71913
       60432
       69209
       58714
       59908
       52055
       44817
       39353
       52824
       44056
       58842
       44939
       52666
       46327
       46577
       54064
       42396
       37473
       48199
       31012
       45119
       25857
       31149
       26647
       21768
       31711
       22848
       18825
       25900
       15234
       27443
       10481
       16352
       13215
       15423
       17784
       11733
        9994
       18131
       10315
       21334
        7699
       10878
        8329
        8855
       11453
       11165
        7346
       15741
       14116
       14253
        5975
        7072
        8492
        5298
        6900
        5584
        4091
       10528
        6667
        9108
        3603
        4718
        4324
        3044
        5651
        6904
        3740
        7956
        4023
        5901
        2961
        3401
        2388
        1975
        2070
        3801
        1817
        3714
        1263
        2331
         613
         819
        1812
        1286
         966
         605
         750
        500];
male = male/sum(male);male = cumsum(male);
female = female/sum(female);female = cumsum(female);
output = unifrnd(0,1,1,n);
if gender =='m'
    output = interp1(male,age,output);
else
    output = interp1(female,age,output);
end

end
