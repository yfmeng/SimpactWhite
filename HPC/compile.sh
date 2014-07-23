#!/bin/bash

source /apps/leuven/etc/bash.bashrc

cd SimpactWhite
module load matlab/R2014a

rm -f trial
mcc -mv -o trial \
    -a ./lib -a ./lib/events -a ./lib/statTools -a ./age_mixing \
    ageMixingStruct.m

