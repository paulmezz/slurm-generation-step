#!/bin/bash -l

#What generation and thread am I?
MY_GENERATION=$1
MY_THREAD=$2

echo "worker ${MY_THREAD} of generation ${MY_GENERATION} reporting in from node $(hostname)"
sleep 10

