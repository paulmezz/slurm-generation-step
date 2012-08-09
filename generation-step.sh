#!/bin/bash -l

#Source files to pull variables from
source ~/.bashrc
source configuration_0809twoweek.sh

#Load IDL/ENVI binaries
module load envi


#Store first two incoming arguments as generation and particle
generation=$1
particle=$2

#Push to directory containing IDL code
pushd /home/mva7609/may_casterline/PSO_Cluster_SLURM/

#Start IDL and pass in a set of commands
# 1. Compile main driving routine (pso_cluster_final_truth)
# 2. Compiel any dependent routines
# 3. Execute main routine, passing into coming arguments as well as configuration file variables
# 4. Print the returned value from the execution
# 5. End the IDL list of compands

idl <<EOF
.compile pso_cluster_final_truth
resolve_all
value = pso_cluster_final_truth('${job}', '${num_particles_per_gen}', '${num_parameters}', '${num_generations}','${ub}','${lb}', '${vmax}', '${alge_constant_path}', '${dataPath}', ${generation}, ${particle}, ${ratio_flag}, ${metric_flag}, ${season}, ${weather_variable}, ${minflag}, ${initial_fwhm}, ${initial_mean} )
print, value
EOF

#Pop out of directory and exit
popd
echo -------
exit

