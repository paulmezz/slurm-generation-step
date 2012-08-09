# alge_constant_path = path containing all ALGE input files and ground truth data
# dataPath = where new data is going to reside

alge_constant_path='/home/mva7609/may_casterline/SLURM/0809_2week_algefiles/'
dataPath='/home/mva7609/may_casterline/SLURM/two_week_runs/0809/data/'
name='2WK0809'
# num_particles_per_gen = how many ALGE instances will run per generation
num_particles_per_gen=3

# num_parameters = how many ALGE inputs that are being optimized
#	=number of points to average the flow file to
#		 --> if only optimizing flow (weather_variable=0)
#		 --> this value is equal to the total number of points
#		     in the flow file, divided by the window size used
#		     to create the new flow array
#		     EXAMPLE: Flow file has 2900 points and user wants 
#			a flow value to be calculated every 145 points.
#			145 is the window size, so there will be 20
#			entries in the flow file, representing a value
#			approixmately every 6 days (assuming the time
#			resolution is hourly).
#	=8 --> if only optimizing weather (weather_variable=1)
#	=10 --> optimizing both weather and flow (weather_variable=2)
num_parameters=20

# num_generations = how many generations the swarm will run for
num_generations=4

# ub = upper bound
# lb = lower bound
# 	These bounds are the bounding condition ranges are different
#	depending on the mode of operation.  
#
#	If optimizing weather or weather and plant parameters these 
#	values represent the range of possible % changes made to the 
#	overall time series.
#
#	If optimizing only flow then these bounds represent the range
#	the flow rate is allowed to fluctuate within at any point in time.
ub=45.0
lb=1.0
vmax=0.5

# weather_variable decides which parameters are optimized
#	=0 --> weather parameters are considered valid and left alone, only
#	       flow is optimized
#	=1 --> weather parameters are the only things optimized
#	=2 --> weather and plant parameters are optimized using % change to 
#	       the overall time series
weather_variable=5

# ratio_flag = determine metric for evaluation
#	1 = ice only
#	2 = water only
#	3 = combination metric
ratio_flag=1

# metric_flag = determine metric used
#	1 = Modified RMS
#	2 = Standard RMS
metric_flag=2
minflag=1
# season = define which season of data to simulate
#	0 = 08/09 winter
#	1 = 09/10 winter
season=0
