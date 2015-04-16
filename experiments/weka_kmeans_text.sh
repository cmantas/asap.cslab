#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/experiment.sh	#loads the experiment function
operator_out="weka_kmeans_text.out"
rm $operator_out &>/dev/null


input_dir=~/Data/ElasticSearch_text_docs
virtual_dir=~/Data/docs_virt_dir
mkdir -p $virtual_dir/text &>/dev/null


sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_tfidf 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, time INTEGER, max_dimensions INTEGER, dimensions INTEGER, date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_kmeans_text 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, k INTEGER, dimensions INTEGER, time INTEGER, date TIMESTAMP);"



for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do
	for (( asked_features=min_dimensions; asked_features<=max_dimensions; asked_features+=dimensions_step)); do
		############### creating virt dir  ###################
		rm $virtual_dir/text/*
		doc_count=0
		for f in $input_dir/*; do
			bn=$(basename $f)
			ln -s $f $virtual_dir/text/$bn
			((doc_count+=window))
			if ((doc_count>=docs)); then break;fi
		
		done
		echo "[PREP] linked $doc_count documents"
		if ((doc_count<docs)); then
			echo could not find enough docs \(found $doc_count of $docs\). exiting
			exit
		fi
		echo "[PREP]: Converting to arff"
		#convert to arff
		$(dirname $0)/../weka/kmeans_text_weka/convert_text_weka.sh $virtual_dir &>$operator_out
		check $operator_out
	
		echo EXPERIMENT: weka tf-idf for $docs documents, up to $asked_features features
		#tfidf
		tstart
		$(dirname $0)/../weka/kmeans_text_weka/tfidf_text_weka.sh  $asked_features &>>weka_tfidf.out
		features_no=$(tail weka_tfidf.out -n 1)
		time=$(ttime)
	       	sqlite3 results.db "INSERT INTO weka_tfidf(documents,dimensions, max_dimensions, time, date )
	            VALUES( $docs,  $features_no,  $asked_features, $time, CURRENT_TIMESTAMP);"
																			
	    	for((k=min_k; k<=max_k; k+=k_step)); do
			echo "EXPERIMENT:  weka_kmeans_text for k=$k, $docs documents"
			#kmeans
			tstart
			$(dirname $0)/../weka/kmeans_text_weka/kmeans_text_weka.sh $k $max_iterations &>>$operator_out
			check $operator_out
	        	time=$(ttime)
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
