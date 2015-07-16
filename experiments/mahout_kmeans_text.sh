#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/common.sh 	#loads the common functions

output_file="mahout_kmeans_text.out"


input_dir=~/Data/ElasticSearch_text_docs
TOOLS_JAR=~/bin/lib/asapTools.jar


#create HDFS files
hadoop_input=./input/kmeans_text_seqfiles
hdfs dfs -rm -r $hadoop_input
hdfs dfs -mkdir -p $hadoop_input

tfidf_dir=/tmp/mahout_tfidf
moved_arff=/tmp/moved_vecs.arff
moved_spark=/tmp/moved_spark; hdfs -mkdir -p $moved_spark &>/dev/null

sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout_tfidf 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, time INTEGER, minDF INTEGER, dimensions INTEGER, metrics TEXT, date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout_kmeans_text 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, k INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT,  date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout2arff
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT,  date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS mahout2spark
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT,  date TIMESTAMP);"



tfidf (){
	docs=$1
	minDF=$2

	monitor_start

	# TF/IDF
	echo -n "[EXPERIMENT] TF-IDF on $docs documents, minDF=$minDF: "
	tstart
	asap tfidf mahout $hadoop_input $tfidf_dir $minDF &> mahout_tfidf.out
	time=$(ttime)
	check mahout_tfidf.out

	# find the dimensions of the output
	dimensions=$(hadoop jar ${TOOLS_JAR}  seqInfo  $tfidf_dir/dictionary.file-0 | grep Lenght: | awk '{ print $2 }')
	echo $dimensions features, $((time/1000)) sec

	metrics=$(monitor_stop)
	
	#save in db
	sqlite3 results.db "INSERT INTO mahout_tfidf(documents, minDF, dimensions, time, metrics, date )
	                    VALUES( $docs, $minDF, $dimensions, $time, '$metrics',  CURRENT_TIMESTAMP);"
}

kmeans(){
	k=$1
	max_iterations=$2
	dimensions=$3
	echo -n "[EXPERIMENT] mahout K-means with K=$k: "
			
	#start monitoring
	asap monitor -f monitoring_data.txt & mpid=$!

	tstart #start timer
	asap kmeans mahout $tfidf_dir $k $max_iterations &> mahout_kmeans.out
	time=$(ttime) #stop timer
	check mahout_kmeans.out
	echo $((time/1000)) sec

	# retreive the monitoring metrics
	kill $mpid; metrics=$(cat monitoring_data.txt); rm monitoring_data.txt

	sqlite3 results.db "INSERT INTO mahout_kmeans_text(documents, k, dimensions, time, metrics, date )
	                    VALUES( $docs,  $k, $dimensions,  $time, '$metrics', CURRENT_TIMESTAMP);"
}

mahout2arff (){
	docs=$1
	dimensions=$2

	monitor_start

	# move mahout to arff
	echo -n "[EXPERIMENT] Move Mahout->arff on $docs documents"
	tstart
	asap move mahout2arff $tfidf_dir $moved_arff &> mahout2arff.out
	time=$(ttime)
	check mahout2arff.out

	echo $dimensions features, $((time/1000)) sec
	
	metrics=$(monitor_stop)

	#save in db
	sqlite3 results.db "INSERT INTO mahout2arff(documents, dimensions, time, metrics, date )
	                    VALUES( $docs, $dimensions, $time, '$metrics',  CURRENT_TIMESTAMP);"
}

mahout2spark (){
	docs=$1
	dimensions=$2

	monitor_start

	# Move mahout to spark
	echo -n "[EXPERIMENT] Move Mahout->Spark on $docs documents"
	tstart
	asap move mahout2spark $tfidf_dir $moved_spark &> mahout2spark.out
	time=$(ttime)
	check mahout2spark.out

	echo $dimensions features, $((time/1000)) sec
	
	metrics=$(monitor_stop)

	#save in db
	sqlite3 results.db "INSERT INTO mahout2spark(documents, dimensions, time, metrics, date )
	                    VALUES( $docs, $dimensions, $time, '$metrics',  CURRENT_TIMESTAMP);"
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
