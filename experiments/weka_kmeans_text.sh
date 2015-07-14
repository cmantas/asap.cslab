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
	time=$(ttime)
	metrics=$(monitor_stop)

	features_no=$(cat $arff_vectors | grep @attribute | wc -l)
	(( features_no=features_no-1 ))

	echo $features_no features, $(($time/1000)) secs
       	sqlite3 results.db "INSERT INTO weka_tfidf(documents,dimensions, minDF, time, metrics, date )
            VALUES( $docs,  $features_no,  $minDF, $time, '$metrics', CURRENT_TIMESTAMP);"
		
}



arff2mahout (){
        docs=$1
        dimensions=$2

        monitor_start

        echo -n "[EXPERIMENT] Move arff->Spark on $docs documents, $dimensions "
        tstart
        asap move arff2mahout $arff_vectors $moved_mahout &> mahout2arff.out
        time=$(ttime)
        check mahout2arff.out

        echo  $((time/1000)) sec
        
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




for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do

		echo "[PREP]: Converting text to arff"
		#convert to arff
		asap move dir2arff $input_dir $arff_data $docs &> dir2arff.out
		check dir2arff.out

	
	for (( minDF=max_minDF; minDF>=min_minDF; minDF-=minDF_step)); do
		echo -n "[EXPERIMENT] weka tf-idf for $docs documents, minDF=$minDF:  "
		
		#tfidf
		tfidf $docs $minDF
		exit
																		
	    	for((k=min_k; k<=max_k; k+=k_step)); do
			echo -n "[EXPERIMENT] weka_kmeans_text for k=$k, $docs documents: "
			#kmeans
			tstart
			asap kmeans weka $tmp_dir/tfidf.arff $k $max_iterations &>weka_kmeans.out
			check weka_kmeans.out

	        	time=$(ttime)
			echo $((time/1000)) secs
	       		sqlite3 results.db "INSERT INTO weka_kmeans_text(documents, k, time, date, dimensions)
	            		VALUES( $docs,  $k, $time, CURRENT_TIMESTAMP, $features_no);"
																			
		done #K parameter loop
		
		# if we got less features than we asked we need not ask for more
		if ((features_no<asked_features));then
			echo No need to add more dimensions, continuing
			break
		fi
	done #asked dimensions loop
done #documents count loop

exit
	

rm -rf tmp 2>/dev/null
