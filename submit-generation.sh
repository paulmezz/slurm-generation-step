#!/bin/bash -l

#TODO
#epilog magic
#put May's job calls in

# This defines a whole bunch of environment variables for us to use!
#This can be omitted and hardcoded below if need-be.  PER USER OPTIONS
source configuration_0809twoweek.sh

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
TOTAL_GENERATIONS=${num_generations}

#Number of job steps to run per generaion
NUM_STEPS=${num_particles_per_gen}

# Just a constant variable used throughout the script to name our jobs
#   in a meaningful way.
JOB_NAME=${name}

#This is the actual file called to do the work (once per step)
#In this setup, it will need to be called with two arguments, generation and step
STEP_WORKER_SCRIPT="generation-step.sh"

#You shouldn't need to edit below this line. 
#Below here are the loops to generate the generational job files with
#The steps inside them


for i in `seq 0 ${TOTAL_GENERATIONS}` ; do

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

# Name of the job - You'll probably want to customize this.
#SBATCH -J ${JOB_NAME}_${GENERATION} 

# Standard out and Standard Error output files
#SBATCH -o ${JOB_NAME}_${GENERATION}.stdout
#SBATCH -e ${JOB_NAME}_${GENERATION}.stderr

# Replace $USER with your username
#SBATCH --mail-user $USER@rit.edu

# notify on state change: BEGIN, END, FAIL or ALL
#SBATCH --mail-type=ALL

##10 min runtime
#SBATCH -t ${SLURM_WALLCLOCK} 

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
	echo magic!
fi

EOF

done

#Old script down there...
exit 0


mkdir -p ${dataPath}output/
dep_list='';
for particle in $(seq 0 $(expr $num_particles_per_gen - 1)) ; do
   outfile=${dataPath}output/output-generation-0-particle-$particle.out
   job=$jobname-0-$particle
   generation=0
   echo "Submitting job $job"
   export particle
   export generation
   command="sbatch \
	--qos=salvaggio-normal \
	-J $job \
	--output=$outfile \
	--error=$outfile \
	$jobfile"
   id=$($command | awk ' { print $4 }')
   echo $id
   dep_list=$id:$dep_list
   echo "latest list $dep_list"
done
echo $dep_list
# Now submit the remaining jobs so that they depend on their predecessors.
for i in `seq 1 $num_generations` ; do
    dep_list=$(echo ${dep_list%\:})
    echo $dep_list
    dep_list_next=''
    for particle in $(seq 0 $(expr $num_particles_per_gen - 1)) ; do
        # Do a little output to see what's up as this executes.
        echo "Submitting my particle $particle in generation ${i} using dep_list $dep_list."

        # Name a file dynamically where we want all of our 'messages' to go.
        outfile=${dataPath}output/output-generation-$i-particle-$particle.out
	generation=$i
	export generation
	export particle
	
	echo "current dep list $dep_list"
	command="sbatch \
		--qos=salvaggio-normal \
		--dependency=afterok:$dep_list \
		-J $jobname-$i-$particle \
		--output=$outfile \
		--error=$outfile \
		$jobfile"
	dep_list_next=$($command | awk ' { print $4 }'):$dep_list_next
    done
    dep_list=$dep_list_next
done
