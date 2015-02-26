#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/experiment.sh	#loads the experiment function
results_file="results/mahout_kmeans_text_experiments.results"
output_file="mahout_kmeans_text.out"
operator_out="mahout_kmeans_text.out"
rm $operator_out &>/dev/null


#first create the hdfs input directory
hdfs dfs -mkdir -p ./input/kmeans_input

#delete results  output file
rm -f results_file 2>/dev/null


input_dir=~/Data/ElasticSearch_text_docs

#echo Putting $input to HDFS
hadoop_input=./input/kmeans_text
hdfs dfs -mkdir -p $hadoop_input/text/

for ((docs=documents_step; docs<=max_documents; docs+=documents_step)); do
        for((clusters=min_clusters; clusters<=max_clusters; clusters+=clusters_step)); do
		file=$(((docs-documents_step)/documents_step))
		
		
		#put input files in hdfs 
		hdfs dfs -put  ${input_dir}/${file} $hadoop_input/text &>/dev/null
					       
		EXPERIMENT_NAME="mahout_kmeans_text: documents $docs, K $clusters"
		OPERATOR_OUTPUT=$operator_out
		EXPERIMENT_OUTPUT=$results_file		
		experiment  $(dirname $0)/../hadoop/mahout-kmeans/mahout_kmeans_text.sh $hadoop_input $clusters $max_iterations
		#$(dirname $0)/../hadoop/mahout-kmeans/mahout_kmeans_text.sh $hadoop_input $clusters $max_iterations
		check $operator_out
	done
done

exit
	

rm -rf tmp 2>/dev/null
