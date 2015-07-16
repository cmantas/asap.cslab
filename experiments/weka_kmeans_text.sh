#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/common.sh         #loads the common functions

rm $operator_out &>/dev/null


input_dir=~/Data/ElasticSearch_text_docs
mkdir -p $virtual_dir/text &>/dev/null

tmp_dir=/tmp/kmeans_weka
arff_vectors=$tmp_dir/tfidf.arff
arff_data=$tmp_dir/data.arff

moved_mahout=/tmp/moved_mahout; hdfs dfs -mkdir -p $moved_mahout &>/dev/null
moved_spark=/tmp/moved_spark; hdfs dfs -mkdir -p $moved_spark &>/dev/null


sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_tfidf 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, time INTEGER, minDF INTEGER, dimensions INTEGER, metrics TEXT, date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_kmeans_text 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, k INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT, date TIMESTAMP);"

sqlite3 results.db "CREATE TABLE IF NOT EXISTS arff2mahout
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT,  date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS arff2spark
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, dimensions INTEGER, time INTEGER, metrics TEXT,  date TIMESTAMP);"


tfidf(){
	docs=$1
	minDF=$2
	tstart
	monitor_start

	asap tfidf weka $arff_data $arff_vectors $minDF &>weka_tfidf.out

	time=$(ttime); metrics=$(monitor_stop)
	check weka_tfidf.out

	dimensions=$(cat $arff_vectors | grep @attribute | wc -l)
	(( dimensions=dimensions-1 ))

	echo $dimensions features, $(($time/1000)) secs
       	sqlite3 results.db "INSERT INTO weka_tfidf(documents,dimensions, minDF, time, metrics, date )
            VALUES( $docs,  $dimensions,  $minDF, $time, '$metrics', CURRENT_TIMESTAMP);"
		
}

kmeans(){
	k=$1
	max_iterations=$2
	dimensions=$4
	docs=$3
	
	echo -n "[EXPERIMENT] weka_kmeans_text for k=$k, $docs documents, $dimensions dimensions: "
	#kmeans
	monitor_start
	tstart

	asap kmeans weka $tmp_dir/tfidf.arff $k $max_iterations &>weka_kmeans.out
	check weka_kmeans.out

	time=$(ttime)
	echo $((time/1000)) secs
	metrics=$(monitor_stop)

	sqlite3 results.db "INSERT INTO weka_kmeans_text(documents, k, time, date, metrics, dimensions)
    		VALUES( $docs,  $k, $time, CURRENT_TIMESTAMP, '$metrics', $dimensions);"
		exit
	
}


arff2mahout (){
        docs=$1
        dimensions=$2

        echo -n "[EXPERIMENT] Move arff->Spark on $docs documents, $dimensions "
        monitor_start; tstart

        asap move arff2mahout $arff_vectors $moved_mahout &> arff2mahout.out
        time=$(ttime);metrics=$(monitor_stop)

        check arff2mahout.out

        echo  $((time/1000)) sec
        
        #save in db
        sqlite3 results.db "INSERT INTO mahout2arff(documents, dimensions, time, metrics, date )
                            VALUES( $docs, $dimensions, $time, '$metrics',  CURRENT_TIMESTAMP);"
}


arff2spark (){
        docs=$1
        dimensions=$2
        
	# Move mahout to spark
        monitor_start; tstart
        echo -n "[EXPERIMENT] Move arff->Spark on $docs documents"
        asap move arff2spark $arff_vectors $moved_spark &> arff2spark.out
        time=$(ttime);metrics=$(monitor_stop)
        check arff2spark.out

        echo $dimensions features, $((time/1000)) sec
        
        #save in db
        sqlite3 results.db "INSERT INTO arff2spark(documents, dimensions, time, metrics, date )
                            VALUES( $docs, $dimensions, $time, '$metrics',  CURRENT_TIMESTAMP);"
}


#################### Main Profiling Loop ####################

for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do

		echo "[PREP]: Converting text to arff"
		#convert to arff
		asap move dir2arff $input_dir $arff_data $docs &> dir2arff.out
		check dir2arff.out

	
	for (( minDF=max_minDF; minDF>=min_minDF; minDF-=minDF_step)); do
		echo -n "[EXPERIMENT] weka tf-idf for $docs documents, minDF=$minDF:  "
		
		#tfidf
		tfidf $docs $minDF

		#arff2mahout
		arff2mahout $docs $dimensions
		
		#arff2spark
		arff2spark $docs $dimensions
																		
	    	for((k=min_k; k<=max_k; k+=k_step)); do
			kmeans $k $max_iterations $docs $dimensions
			exit																		
		done #K parameter loop
		
		# if we got less features than we asked we need not ask for more
		if ((dimensions<asked_features));then
			echo No need to add more dimensions, continuing;break
		fi

	done #asked dimensions loop
done #documents count loop

exit
	

rm -rf tmp 2>/dev/null
