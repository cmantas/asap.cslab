#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/experiment.sh	#loads the experiment function
output_file="mahout_kmeans_text.out"
operator_out="mahout_kmeans_text.out"
rm $operator_out &>/dev/null


#first create the hdfs input directory
#hdfs dfs -mkdir -p ./input/kmeans_input



input_dir=~/Data/ElasticSearch_text_docs

#echo Putting $input to HDFS
hadoop_input=./input/kmeans_text
#hdfs dfs -mkdir -p $hadoop_input/text/

#helper vars for the input files
doc_count=0
file=0

for ((docs=documents_step; docs<=max_documents; docs+=documents_step)); do
		echo "[PREP] putting text files to HDFS"
		#put the necessary input files to hdfs
		while ((doc_count<docs)); do
			((file+=1))
			((doc_count+=window))
			#put input files in hdfs 
			hdfs dfs -put  ${input_dir}/${file} $hadoop_input &>/dev/null
		done

		### we need to run text to sequence file and tf/idf only once for the given doc count ###

		# Text to sequence
		echo "[PREP] text files --> sequence file"
		$(dirname $0)/../hadoop/mahout-kmeans/mahout_text2seq.sh $hadoop_input

		# TF/IDF
		EXPERIMENT_NAME="mahout_tfidf: documents $docs , K 0"
		OPERATOR_OUTPUT=$operator_out	
		experiment  $(dirname $0)/../hadoop/mahout-kmeans/mahout_tfidf.sh
		check $operator_out

		### For each of value of K run KMeans ###
        for((clusters=min_clusters; clusters<=max_clusters; clusters+=clusters_step)); do
			EXPERIMENT_NAME="mahout_kmeans_text: documents $docs , K $clusters"
			OPERATOR_OUTPUT=$operator_out
			experiment  $(dirname $0)/../hadoop/mahout-kmeans/mahout_kmeans_text.sh $hadoop_input $clusters $max_iterations
			check $operator_out
	done
done

exit
	

rm -rf tmp 2>/dev/null
