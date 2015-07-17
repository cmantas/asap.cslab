#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/common.sh 	#loads the common functions


input_dir=~/Data/ElasticSearch_text_docs
TOOLS_JAR=~/bin/lib/asapTools.jar


#create HDFS files
hadoop_input=./input/kmeans_text_seqfiles
mahout_raw_clusters=/tmp/clusters_raw
hdfs dfs -rm -r $hadoop_input
hdfs dfs -mkdir -p $hadoop_input

tfidf_dir=/tmp/mahout_tfidf
moved_arff=/tmp/moved_vecs.arff
moved_spark=/tmp/moved_spark; hdfs -mkdir -p $moved_spark &>/dev/null

sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout_tfidf 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, time INTEGER, minDF INTEGER, 
	dimensions INTEGER, metrics TEXT, input_size INTEGER, output_size INTEGER, date DATE DEFAULT (datetime('now','localtime')));"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout_kmeans_text 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, k INTEGER, dimensions INTEGER, 
time INTEGER, metrics TEXT, input_size INTEGER, output_size INTEGER, date DATE DEFAULT (datetime('now','localtime')));"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout2arff
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT, input_size INTEGER, output_size INTEGER, date DATE DEFAULT (datetime('now','localtime')));"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout2spark
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT, input_size INTEGER, output_size INTEGER, date DATE DEFAULT (datetime('now','localtime')));"



tfidf (){
	docs=$1
	minDF=$2


	# TF/IDF
	echo -n "[EXPERIMENT] TF-IDF on $docs documents, minDF=$minDF: "
	input_size=$(hdfs_size $hadoop_input)
	tstart; monitor_start
	asap tfidf mahout $hadoop_input $tfidf_dir $minDF &> mahout_tfidf.out
	time=$(ttime); metrics=$(monitor_stop)
	output_size=$(hdfs_size $tfidf_dir)
	check mahout_tfidf.out

	# find the dimensions of the output
	dimensions=$(hadoop jar ${TOOLS_JAR}  seqInfo  $tfidf_dir/dictionary.file-0 | grep Lenght: | awk '{ print $2 }')
	echo $dimensions features, $((time/1000)) sec

	
	#save in db
	sqlite3 results.db "INSERT INTO mahout_tfidf(documents, minDF, dimensions, time, metrics, input_size, output_size)
	                    VALUES( $docs, $minDF, $dimensions, $time, '$metrics',  $input_size, $output_size);"
}

kmeans(){
	k=$1
	max_iterations=$2
	dimensions=$3
	echo -n "[EXPERIMENT] mahout K-means with K=$k: "
			
	#start monitoring
	in_size=$(hdfs_size $tfidfs_dir)
	tstart; monitor_start
	asap kmeans mahout $tfidf_dir $k $max_iterations $mahout_raw_clusters &> mahout_kmeans.out
	time=$(ttime); metrics=$(monitor_stop)
	check mahout_kmeans.out
	out_size=$(hdfs_size $mahout_raw_clusters)
	echo $((time/1000)) sec

	sqlite3 results.db "INSERT INTO mahout_kmeans_text(documents, k, dimensions, time, metrics, input_size, output_size)
	                    VALUES( $docs,  $k, $dimensions,  $time, '$metrics', $in_size, $out_size);"
}

mahout2arff (){
	docs=$1
	dimensions=$2


	# move mahout to arff
	echo -n "[EXPERIMENT] Move Mahout->arff on $docs documents "
	input_size=$(hdfs_size $tfidf_dir)
	tstart; monitor_start
	asap move mahout2arff $tfidf_dir $moved_arff &> mahout2arff.out
	time=$(ttime)
	check mahout2arff.out
	output_size=$(size $moved_arff)

	echo $dimensions features, $((time/1000)) sec
	
	metrics=$(monitor_stop)

	#save in db
	sqlite3 results.db "INSERT INTO mahout2arff(documents, dimensions, time, metrics, input_size, output_size)
	                    VALUES( $docs, $dimensions, $time, '$metrics',  $input_size, $output_size);"
}

mahout2spark (){
	docs=$1
	dimensions=$2

	# Move mahout to spark
	echo -n "[EXPERIMENT] Move Mahout->Spark on $docs documents "
	tstart; monitor_start
	input_size=$(hdfs_size $tfidf_dir)
	asap move mahout2spark $tfidf_dir $moved_spark &> mahout2spark.out
	time=$(ttime); metrics=$(monitor_stop)
	check mahout2spark.out
	output_size=$(hdfs_size $moved_spark)

	echo $dimensions features, $((time/1000)) sec
	

	#save in db
	sqlite3 results.db "INSERT INTO mahout2spark(documents, dimensions, time, metrics, input_size, output_size)
	                    VALUES( $docs, $dimensions, $time, '$metrics', $input_size, $output_size);"
}


###################### Main Profiling Loops #########################

for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do
	#re-load the parameters on each iteration for live re-configuration
	source  $(dirname $0)/config.info 	#loads the parameters

	echo "[PREP] Loading $docs text files"
	asap move dir2sequence $input_dir $hadoop_input $docs &> dir2sequence.out
	check dir2sequence.out
	
	for (( minDF=max_minDF; minDF>=min_minDF; minDF-=minDF_step)); do

	
		#TF-IDF
		tfidf $docs $minDF

		#Mahout to Arff
		mahout2arff $docs $dimensions
		
		#Mahout to Spark
		mahout2spark $docs $dimensions
	
	   	#Loop for the various values of K parameter
		for((k=min_k; k<=max_k; k+=k_step)); do
			kmeans $k $max_iterations $dimensions
			exit
		done
	done
done

exit
	

rm -rf tmp 2>/dev/null
