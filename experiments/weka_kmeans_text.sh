#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/experiment.sh	#loads the experiment function
operator_out="weka_kmeans_text.out"
rm $operator_out &>/dev/null


input_dir=~/Data/ElasticSearch_text_docs
virtual_dir=~/Data/docs_virt_dir
mkdir -p $virtual_dir/text &>/dev/null


sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_tfidf 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, time INTEGER, minDF INTEGER, dimensions INTEGER, date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_kmeans_text 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, k INTEGER, dimensions INTEGER, time INTEGER, date TIMESTAMP);"



for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do
		############### creating virt dir  ###################
		rm $virtual_dir/text/*
		echo -n  "[PREP] linking $docs documents: "
		doc_count=0
		for f in $input_dir/*; do
			bn=$(basename $f)
			ln -s $f $virtual_dir/text/$bn
			((doc_count+=1))
			if ((doc_count>=docs)); then break;fi
		
		done
		echo "OK ($doc_count) "
		if ((doc_count<docs)); then
			echo could not find enough docs \(found $doc_count of $docs\). exiting
			exit
		fi
		echo "[PREP]: Converting to arff"
		#convert to arff
		$(dirname $0)/../weka/kmeans_text_weka/convert_text_weka.sh $virtual_dir &>$operator_out
		check $operator_out
	
	for (( minDF=max_minDF; minDF>=min_minDF; minDF-=minDF_step)); do
		echo -n "[EXPERIMENT] weka tf-idf for $docs documents, minDF=$minDF:  "
		#tfidf
		tstart
		$(dirname $0)/../weka/kmeans_text_weka/tfidf_text_weka.sh  9999999 $minDF &>>weka_tfidf.out
		features_no=$(tail weka_tfidf.out -n 1)
		time=$(ttime)
		echo $features_no features, $(($time/1000)) secs
	       	sqlite3 results.db "INSERT INTO weka_tfidf(documents,dimensions, minDF, time, date )
	            VALUES( $docs,  $features_no,  $minDF, $time, CURRENT_TIMESTAMP);"
																			
	    	for((k=min_k; k<=max_k; k+=k_step)); do
			echo -n "[EXPERIMENT] weka_kmeans_text for k=$k, $docs documents: "
			#kmeans
			tstart
			$(dirname $0)/../weka/kmeans_text_weka/kmeans_text_weka.sh /tmp/kmeans_text_weka/tf_idf_data.arff $k $max_iterations &>>$operator_out
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
