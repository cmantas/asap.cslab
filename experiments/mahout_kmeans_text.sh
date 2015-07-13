#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters

output_file="mahout_kmeans_text.out"
operator_out="mahout_kmeans_text.out"
rm $operator_out &>/dev/null


input_dir=~/Data/ElasticSearch_text_docs
TOOLS_JAR=~/bin/lib/asapTools.jar


#create HDFS files
hadoop_input=./input/kmeans_text_seqfiles
hdfs dfs -rm -r $hadoop_input
hdfs dfs -mkdir -p $hadoop_input

tfidf_dir=/tmp/mahout_tfidf

sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout_tfidf 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, time INTEGER, minDF INTEGER, dimensions INTEGER, date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout_kmeans_text 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, k INTEGER, dimensions INTEGER, time INTEGER, date TIMESTAMP);"

for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do
	#re-load the parameters on each iteration for live re-configuration
	source  $(dirname $0)/config.info 	#loads the parameters

	echo "[PREP] Loading $docs text files"
	asap move dir2sequence $input_dir $hadoop_input $docs &>> $operator_out
	
	for (( minDF=max_minDF; minDF>=min_minDF; minDF-=minDF_step)); do

		#start monitoring
		asap monitor > monitoring_data.txt & mpid=$!

		# TF/IDF
		echo -n "[EXPERIMENT] TF-IDF on $docs documents, minDF=$minDF: "
		tstart
		asap tfidf mahout $hadoop_input $tfidf_dir $minDF &>> $operator_out
		time=$(ttime)
		check $operator_out
		
		# retreive the monitoring metrics
		kill $mpid; metrics=$(cat monitoring_data.txt); rm montoring_data.txt
		echo $metrics
		exit

		# find the dimensions of the output
		dimensions=$(hadoop jar ${TOOLS_JAR}  seqInfo  $tfidf_dir/dictionary.file-0 | grep Lenght: | awk '{ print $2 }')
		echo $dimensions features, $((time/1000)) sec
		#save in db
		sqlite3 results.db "INSERT INTO mahout_tfidf(documents, minDF, dimensions, time, date )
		                    VALUES( $docs, $minDF, $dimensions, $time, CURRENT_TIMESTAMP);"
	
		for((k=min_k; k<=max_k; k+=k_step)); do
			echo -n "[EXPERIMENT] mahout K-means with K=$k: "
			tstart
			asap kmeans mahout $tfidf_dir $k $max_iterations &>> $operator_out
			time=$(ttime)
			check $operator_out
			echo $((time/1000)) sec
			sqlite3 results.db "INSERT INTO mahout_kmeans_text(documents, k, dimensions, time, date )
			                    VALUES( $docs,  $k, $dimensions,  $time, CURRENT_TIMESTAMP);"
		done
	done
done

exit
	

rm -rf tmp 2>/dev/null
