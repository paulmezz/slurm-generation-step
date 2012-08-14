#!/bin/bash -l

#What generation and thread am I?
MY_GENERATION=$1
MY_THREAD=$2

echo "I am worker ${MY_THREAD} of generation ${MY_GENERATION}"
echo "\"working\" for 10 seconds"
sleep 10

