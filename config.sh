#!/bin/bash

if [ "$BASH_SOURCE" == $0 ] ; then echo "This is a config file, you don't run it" ; exit 1 ; fi

##Slurm config options##

#QoS to run in
SLURM_QOS="rc-normal"

#Slurm partiton
SLURM_PARTITION="work"

#Memory requiremnt PER JOB (total, not per job step)
SLURM_MEMORY_REQ="30"

#Runtime limit PER JOB
SLURM_WALLCLOCK="0:10:0"


##Job Options##

#A prefix for all the log files, job names etc.  Spaces are bad.
JOB_PREFIX='gen'

#How many generations the job will run for (how deep the job is)
NUM_GENERATIONS=5

#How many workers will run per generation (how wide the job is)
NUM_STEPS=3

#How many processors each step will consume.
THREADS_PER_STEP=1

#This is the script that is called for ever step.  It is passed two options
# The first option is a number (index 0) which is the generaion
# The second option is a number (index 0) which is the step.
#  Generation 5, worker 2's run will look like "generation-step.sh 5 2"
STEP_WORKER_SCRIPT="generation-step.sh"
