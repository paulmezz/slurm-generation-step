#!/bin/bash -l

# This defines a whole bunch of environment variables for us to use!
source configuration_0809twoweek.sh

# Just a constant variable used throughout the script to name our jobs
#   in a meaningful way.
jobname=$name

# Another constant variable used to name the sge submission file that
#   this script is going to submit to sge.
jobfile="default-job-file.sh"

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
