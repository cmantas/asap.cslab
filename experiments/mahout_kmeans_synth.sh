#!/bin/bash
source config.info 	#loads the parameters
source experiment.sh	#loads the experiment function
results_file="results/mahout_kmeans_synth_experiments.results"
output_file="mahout_kmeans_synth.out"

#first create the hdfs input directory
hdfs dfs -mkdir -p ./input/kmeans_input

#delete operator output file
rm -f results_file 2>/dev/null


for ((points=min_points; points<=max_points; points+=points_step)); do   
	for((clusters=min_clusters; clusters<=max_clusters; clusters+=clusters_step)); do
		#generate the data (if not exists)              
	        ../numerical_generator/generator.py -n $points -c $clusters -o ~/Data/synth_clusters
		fname=${points}_points_${clusters}_clusters.csv
		input=~/Data/synth_clusters/$fname
		
		#put input files in hdfs (ignore failure)
		#echo Putting $input to HDFS
		hdfs dfs -put  -f ${input} ./input/kmeans_input &>/dev/null
		EXPERIMENT_NAME="mahout_kmeans_synth: points $points , K $clusters"
		OPERATOR_OUTPUT=$output_file
		EXPERIMENT_OUTPUT=$results_file		
		hadoop_input="./input/kmeans_input/$fname"
		experiment ../hadoop/mahout-kmeans/mahout_kmeans_synth.sh $hadoop_input $clusters $max_iterations
		check $output_file
                
		#delete the data for the next run
		echo $input
		rm $input

	done
done

rm -rf tmp 2>/dev/null
