#!/bin/bash

for job_id in {3098111..3099221}; do 
	scancel $job_id
done
