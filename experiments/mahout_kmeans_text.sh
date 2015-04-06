#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
output_file="mahout_kmeans_text.out"
operator_out="mahout_kmeans_text.out"
rm $operator_out &>/dev/null


input_dir=~/Data/ElasticSearch_text_docs
TOOLS_JAR=~/bin/lib/asapTools.jar


#create HDFS files
hadoop_input=./input/kmeans_text
hdfs dfs -rm -r $hadoop_input
hdfs dfs -mkdir -p $hadoop_input

#helper vars for the input files
doc_count=0
file=0

for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do
		echo -n "[PREP] putting text files to HDFS: "
		#put the necessary input files to hdfs
		while ((doc_count<docs)); do
			((file+=1))
			((doc_count+=window))
			#put input files in hdfs 
			echo -n "$file, "
			hdfs dfs -put  ${input_dir}/${file} $hadoop_input &>/dev/null
		done
		echo ""

		### we need to run text to sequence file and tf/idf only once for the given doc count ###

		# Text to sequence
		echo "[PREP] text files --> sequence file"
		$(dirname $0)/../hadoop/mahout-kmeans/mahout_text2seq.sh $hadoop_input

		# TF/IDF
		$(dirname $0)/../hadoop/mahout-kmeans/mahout_tfidf.sh >$operator_out
		check $operator_out
		dimensions=$(hadoop jar ${TOOLS_JAR}  SequenceInfo  /tmp/mahout_kmeans/sparce_matrix_files/dictionary.file-0 | grep Lenght: | awk '{ print $2 }')
		echo Dimensions= $dimensions
		exit
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
