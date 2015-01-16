#!/bin/bash
source config.info 	#loads the parameters
source experiment.sh	#loads the experiment function


#first create the hdfs input directory
hdfs dfs -mkdir -p ./input/kmeans_input

for ((points=min_points; points<=max_points; points+=points_step)); do   
	for((clusters=min_clusters; clusters<=max_clusters; clusters+=clusters_step)); do
		fname=${points}_points_${clusters}_clusters.csv
		input=~/Data/synth_clusters/$fname
		
		#put input files in hdfs (ignore failure)
		echo Putting $input to HDFS
		hdfs dfs -put  ${input} ./input/kmeans_input
		exp_name="Mahout KMeans: $points points, K=$clusters"
		OPERATOR_OUTPUT="mahout_kmeans.out"
		EXPERIMENT_OUTPUT="mahout_kmeans_experiments_result.info"
		
		hadoop_input="./input/kmeans_input/$fname"
		experiment ../hadoop/mahout-kmeans/mahout_kmeans_synth.sh $hadoop_input $clusters
	done
done
