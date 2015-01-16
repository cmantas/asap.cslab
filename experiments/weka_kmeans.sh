#!/bin/bash
source config.info 	#loads the parameters
source experiment.sh	#loads the experiment function



for ((points=min_points; points<=max_points; points+=points_step)); do   
	for((clusters=min_clusters; clusters<=max_clusters; clusters+=clusters_step)); do
		input=~/Data/synth_clusters/${points}_points_${clusters}_clusters.csv
		exp_name="Weka KMeans: $points points, K=$clusters"
		OPERATOR_OUTPUT="weka_kmeans.out"
		EXPERIMENT_OUTPUT="weka_kmeans_experiments_result.info"
		experiment java -jar ~/bin/lib/kmeans_weka.jar $input $clusters
	done
done
