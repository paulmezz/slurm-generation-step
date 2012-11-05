#!/bin/bash

#TODO
#release generation 0 upon completion
#have a trigger on success to cancel remaining jobs

#Pull the config then do sanity tests
if [ -e config.sh ] ; then source config.sh ; else echo config file missing! ; exit 1 ; fi

if [ -z "$JOB_NAME" ] ; then echo "JOB_NAME not defined, this is used to prefix all jobs and logs (it should be unique per data set)" ; exit 1 ; fi

if [ -z "$JOB_FILE_DIRECTORY" ] ; then echo JOB_FILE_DIRECTORY not defined, this is where the job files are kept ; exit 1 ; fi
if [ ! -d ${JOB_FILE_DIRECTORY} ] ; then creating job file directory: $JOB_FILE_DIRECTORY ; mkdir -p ${JOB_FILE_DIRECTORY} ; fi

if [ -z "$LOG_FILE_DIRECTORY" ] ; then echo "Warning: LOG_FILE_DIRECTORY not defined, this is where the log files are kept." ; echo "You should ctrl-c a few times and fix this or else you may end up with lots of files in annoying places." ; echo "You have 15 seconds." ; sleep 15 ; fi
if [ ! -d ${LOG_FILE_DIRECTORY} ] ; then echo "LOG_FILE_DIRECTORY $LOG_FILE_DIRECTORY not found, creating" ; mkdir -p ${LOG_FILE_DIRECTORY} ; fi

if [ -z "$TOTAL_GENERATIONS" ] ; then echo "TOTAL_GENERATIONS not defined, this is how many generations deep the job is." ; exit 1 ; fi
if [ -z "$NUM_STEPS" ] ; then echo "NUM_STEPS not defined, this is how many workers run per generation." ; exit 1 ; fi
if [ -z "$THREADS_PER_STEP" ] ; then echo "THREADS_PER_STEP not defined, this is how many processors each step requires." ; exit 1 ; fi
if [ -z "$STEP_WORKER_SCRIPT" ] ; then echo "STEP_WORKER_SCRIPT not defined, this is what is run on every job step." ; exit 1 ; fi

#End sanity tests
###############################################################################
#Below here are the loops to generate the generational job files with
#The steps inside them

#if any job files exit with this prefix, fail
if [ "$(ls jobfiles/${JOB_PREFIX}_*.sh 2> /dev/null)" ] ; then echo "Error, job files exist with this prefix" ; exit 1 ; fi

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
#SBATCH -p ${SLURM_PARTITION} -n ${NUM_STEPS} -c ${THREADS_PER_STEP}

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
	echo "srun -n 1 -c ${THREADS_PER_STEP} -o ${LOG_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}_${STEPNUMBER}.log ${STEP_WORKER_SCRIPT} ${GENERATION} ${STEPNUMBER} &" >> ${JOB_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}.sh
done
#End Step Loop#

cat << EOF >> ${JOB_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}.sh
#wait for above jobs to finish
wait

#release the next generation
if [ "$GENERATION" -lt "$TOTAL_GENERATIONS" ] then
	scontrol release \$(squeue --noheader --format "%.i,%.j" | grep ",${JOB_NAME}_$(expr ${GENERATION} + 1 )$" | cut -f 1 -d ,)
fi

fi

EOF

#Lets submit the new job file
sbatch --hold ${JOB_FILE_DIRECTORY}/${JOB_NAME}_${GENERATION}.sh

done
#End Generation Loop#

