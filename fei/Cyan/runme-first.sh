#!/bin/bash

echo "Current directory is: `pwd`"
echo "Setting DYLD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH=`pwd`/libs/
echo "DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH"

