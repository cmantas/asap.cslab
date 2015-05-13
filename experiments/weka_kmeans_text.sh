#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/experiment.sh	#loads the experiment function
operator_out="weka_kmeans_text.out"
rm $operator_out &>/dev/null


input_dir=~/Data/ElasticSearch_text_docs
mkdir -p $virtual_dir/text &>/dev/null

tmp_dir=/tmp/kmeans_weka


sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_tfidf 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, time INTEGER, minDF INTEGER, dimensions INTEGER, date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_kmeans_text 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, k INTEGER, dimensions INTEGER, time INTEGER, date TIMESTAMP);"



for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do

		echo "[PREP]: Converting to arff"
		#convert to arff
		asap move dir2arff $input_dir $tmp_dir/data.arff $docs &>$operator_out
		check $operator_out
	
	for (( minDF=max_minDF; minDF>=min_minDF; minDF-=minDF_step)); do
		echo -n "[EXPERIMENT] weka tf-idf for $docs documents, minDF=$minDF:  "
		#tfidf
		tstart
		asap tfidf weka $tmp_dir/data.arff $tmp_dir/tfidf.arff $minDF &>$operator_out
		time=$(ttime)
		features_no=$(cat $tmp_dir/tfidf.arff | grep @attribute | wc -l)
		(( features_no=features_no-1 ))

		echo $features_no features, $(($time/1000)) secs
	       	sqlite3 results.db "INSERT INTO weka_tfidf(documents,dimensions, minDF, time, date )
	            VALUES( $docs,  $features_no,  $minDF, $time, CURRENT_TIMESTAMP);"
																			
	    	for((k=min_k; k<=max_k; k+=k_step)); do
			echo -n "[EXPERIMENT] weka_kmeans_text for k=$k, $docs documents: "
			#kmeans
			tstart
			asap kmeans weka $tmp_dir/tfidf.arff $k $max_iterations &>>$operator_out
			check $operator_out
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
