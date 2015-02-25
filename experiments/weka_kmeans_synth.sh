#!/bin/bash
source config.info 	#loads the parameters
source experiment.sh	#loads the experiment function

results_file="weka_kmeans_synth_experiments_.results"

rm weka_kmeans_synth.out
for ((points=min_points; points<=max_points; points+=points_step)); do   
	for((clusters=min_clusters; clusters<=max_clusters; clusters+=clusters_step)); do
		input=~/Data/synth_clusters/${points}_points_${clusters}_clusters.csv
		EXPERIMENT_NAME="Weka KMeans synth : $points points, K=$clusters"
		OPERATOR_OUTPUT="weka_kmeans_synth.out"
		EXPERIMENT_OUTPUT=$results_file
		experiment java -jar ~/bin/lib/kmeans_weka.jar $input $clusters
	done
done
