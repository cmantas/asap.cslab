#!/bin/bash
source config.info 	#loads the parameters
source experiment.sh	#loads the experiment function


rm weka_kmeans_synth.out
for ((points=min_points; points<=max_points; points+=points_step)); do   
	for((clusters=min_clusters; clusters<=max_clusters; clusters+=clusters_step)); do
		for ((i=1; i<=$runs; i++)); do
			#generate the data (if not exists)		
			../numerical_generator/generator.py -n $points -c $clusters -o ~/Data/synth_clusters
			input=~/Data/synth_clusters/${points}_points_${clusters}_clusters.csv
			EXPERIMENT_NAME="weka_kmeans_synth: points $points , K $clusters"
			OPERATOR_OUTPUT="weka_kmeans_synth.out"
			experiment java -jar ~/bin/lib/kmeans_weka.jar $input $clusters $max_iterations 
			#delete the data for the next run
			rm ~/Data/synth_clusters/*
		done
	done
done
