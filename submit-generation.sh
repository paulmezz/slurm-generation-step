#!/bin/bash

#TODO
#epilog magic
#if jobfiles exist, exit with error
#actually submit!

# This defines a whole bunch of environment variables for us to use!
#This can be omitted and hardcoded below if need-be.  PER USER OPTIONS
source example_config.sh

#IMPORTANT!!!!   CHANGE THESE#
SLURM_QOS="rc-normal"
SLURM_PARTITION="debug"
SLURM_MEMORY_REQ="30"
SLURM_WALLCLOCK="0:10:0"

#Where are the job files being created before sumbission?
JOB_FILE_DIRECTORY="./jobfiles"
if [ ! -d ${JOB_FILE_DIRECTORY} ] ; then mkdir -p ${JOB_FILE_DIRECTORY} ; fi

#Where do we dump log files?  (stdout and stderr)
LOG_FILE_DIRECTORY="./logs"
if [ ! -d ${LOG_FILE_DIRECTORY} ] ; then mkdir -p ${LOG_FILE_DIRECTORY} ; fi

#Total number of generations to run through
TOTAL_GENERATIONS=${NUM_GENERATIONS}

#Number of job steps to run per generaion
NUM_STEPS=${NUM_THREADS}

# Just a constant variable used throughout the script to name our jobs
# in a meaningful way.
JOB_NAME=${JOB_PREFIX}

#This is the actual file called to do the work (once per step)
#In this setup, it will need to be called with two arguments, generation and step
STEP_WORKER_SCRIPT="generation-step.sh"

#You shouldn't need to edit below this line. 
#Below here are the loops to generate the generational job files with
#The steps inside them
###############################################################################

#if any job files exit with this prefix, fail
if [ "$(ls jobfiles/gen_*.sh 2> /dev/null)" ] ; then echo "Error, job files exist with this prefix" ; exit 1 ; fi

#Begin Generation Loop#
for GENERATION in $(seq 0 $( expr ${TOTAL_GENERATIONS} - 1)) ; do

cat << EOF >> ${JOB_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}.sh
#!/bin/bash -l
# NOTE the -l flag!
#

# This is an example job file for a single core CPU bound program
# Note that all of the following statements below that begin
# with #SBATCH are actually commands to the SLURM scheduler.
# Please copy this file to your home directory and modify it
# to suit your needs.
# 
# If you need any help, please email rc-help@rit.edu
#

# Name of the job
#SBATCH -J ${JOB_NAME}_${GENERATION} 

# Standard out and Standard Error output files
#SBATCH -o ${LOG_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}.stdout
#SBATCH -e ${LOG_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}.stderr

# Replace $USER with your username
#SBATCH --mail-user $USER@rit.edu

# notify on state change: BEGIN, END, FAIL or ALL
#SBATCH --mail-type=ALL

#Runtime Required
#SBATCH -t ${SLURM_WALLCLOCK} 

#QOS to run under
#SBATCH --qos=${SLURM_QOS}

#Partition and CPUs required
#SBATCH -p ${SLURM_PARTITION} -c ${NUM_STEPS}

# Job memory requirements in MB
#SBATCH --mem=${SLURM_MEMORY_REQ}

# A check to see if this script is managed by SLURM
/usr/bin/env | grep SLURM_JOB_ID
if [ "$?" != "0" ] ; then
    echo "Please run this script with 'sbatch <script-name>'"
    echo "Email rc-help@rit.edu if you have any questions."
    echo "Aborting."
else

EOF

#Begin Step Loop#
for STEPNUMBER in $(seq 0 $(expr ${NUM_STEPS} - 1) ) ; do
	echo "srun -c 1 ${STEP_WORKER_SCRIPT} ${GENERATION} ${STEPNUMBER} &" >> ${JOB_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}.sh
done
#End Step Loop#

cat << EOF >> ${JOB_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}.sh
#wait for above jobs to finish
wait

#release the next generation
scontrol release \$(squeue --noheader --format "%.i,%.j" | grep ",${JOB_NAME}_$(expr ${GENERATION} + 1 )$" | cut -f 1 -d ,)

fi

EOF

#Lets submit the new job file
sbatch --hold ${JOB_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}.sh

done
#End Generation Loop#

#TODO
#Release job 0
