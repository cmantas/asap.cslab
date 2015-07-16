#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/common.sh 	#loads the common functions


output_file="spark_kmeans_text.out"

input_dir=~/Data/ElasticSearch_text_docs
TOOLS_JAR=~/bin/lib/asapTools.jar


#create HDFS files
hadoop_input=/user/$USER/input/kmeans_text_seqfiles
hdfs dfs -rm -r $hadoop_input &>/dev/null
hdfs dfs -mkdir -p $hadoop_input &>/dev/null

spark_vectors=/tmp/spark_tfidf
moved_mahout=/tmp/moved_mahout; hdfs dfs -mkdir -p $moved_mahout
moved_arff=/tmp/moved_vectors.arff

sqlite3 results.db "CREATE TABLE IF NOT EXISTS spark_tfidf 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, time INTEGER, minDF INTEGER, dimensions INTEGER, metrics, date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS spark_kmeans_text 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, k INTEGER, dimensions INTEGER, time INTEGER, date TIMESTAMP);"

sqlite3 results.db "CREATE TABLE IF NOT EXISTS spark2mahout
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT,  date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS spark2arff
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT,  date TIMESTAMP);"


spark_tfidf(){
	docs=$1
	minDF=$2

	# TF/IDF
	hdfs dfs -rm -r $spark_vectors &>/dev/null
	echo -n "[EXPERIMENT] TF-IDF on $docs documents, minDF=$minDF: "
	
	tstart; monitor_start

	asap tfidf spark $hadoop_input $spark_vectors $minDF &> spark_tfidf.out
	time=$(ttime); metrics=$(monitor_stop)

	check_spark spark_tfidf.out
	dimensions=1048576

	echo $dimensions features, $((time/1000)) sec
	#save in db
	sqlite3 results.db "INSERT INTO spark_tfidf(documents, minDF, dimensions, time, metrics, date )
	                    VALUES( $docs, $minDF, $dimensions, $time, '$metrics', CURRENT_TIMESTAMP);"


}

spark_kmeans(){
	echo -n "[EXPERIMENT] spark K-means with K=$k: "
	tstart; monitor_start
	asap kmeans spark $spark_vectors $k $max_iterations &> spark_kmeans.out
	
	time=$(ttime); metrics=$(monitor_stop)
	
	#check_spark spark_kmeans.out # IDK why this fails (OK is never printed)

	rm -r /tmp/spark* 2>/dev/null
	echo $((time/1000)) sec
	
	#DEBUG show any exceptions but igore them
	cat spark_kmeans.out | grep Exception\
	
	sqlite3 results.db "INSERT INTO spark_kmeans_text(documents, k, dimensions, time, metrics, date )
			                    VALUES( $docs,  $k, $dimensions,  $time, '$metrics', CURRENT_TIMESTAMP);"
	
}



spark2mahout(){
        docs=$1
        dimensions=$2

        # Move spark to mahout

	monitor_start; tstart
        echo -n "[EXPERIMENT] Move Spark->Mahout on $docs documents"
        asap move spark2mahout $spark_vectors $moved_mahout &> spark2mahout.out
        time=$(ttime);metrics=$(monitor_stop)
        check spark2mahout.out

        echo $((time/1000)) sec

        #save in db
        sqlite3 results.db "INSERT INTO spark2mahout(documents, dimensions, time, metrics, date )
                            VALUES( $docs, $dimensions, $time, '$metrics',  CURRENT_TIMESTAMP);"
}

spark2arff(){
        docs=$1
        dimensions=$2

        # Move spark to arff
        monitor_start; tstart
        echo -n "[EXPERIMENT] Move Spark->arff on $docs documents"
        asap move spark2arff $spark_vectors $moved_arff &> arff2spark.out
        time=$(ttime);metrics=$(monitor_stop)
        check arff2spark.out

        echo , $((time/1000)) sec

        #save in db
        sqlite3 results.db "INSERT INTO arff2spark(documents, dimensions, time, metrics, date )
                            VALUES( $docs, $dimensions, $time, '$metrics',  CURRENT_TIMESTAMP);"
}



for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do
	#re-load the parameters on each iteration for live re-configuration

	hdfs dfs -rm -r $hadoop_input &>/dev/null
	echo "[PREP] Loading $docs text files"
	asap move dir2sequence $input_dir $hadoop_input $docs &> dir2sequence.out
	check dir2sequence.out

	
	for (( minDF=max_minDF; minDF>=min_minDF; minDF-=minDF_step)); do

		spark_tfidf $docs $minDF
	
		#spark2mahout $docs $dimensions
		#spark2arff $docs  $dimensions

		for((k=min_k; k<=max_k; k+=k_step)); do
			spark_kmeans $k $max_iterations $docs $dimensions
			exit
		done
	done
done

exit
	

rm -rf tmp 2>/dev/null
