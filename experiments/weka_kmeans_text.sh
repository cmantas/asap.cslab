#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/experiment.sh	#loads the experiment function
operator_out="weka_kmeans_text.out"
rm $operator_out &>/dev/null


input_dir=~/Data/ElasticSearch_text_docs
virtual_dir=~/Data/docs_virt_dir
rm -rf $virtual_dir 2>/dev/null
mkdir -p $virtual_dir/text


sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_tfidf 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, percentage INTEGER, time INTEGER, dimensions INTEGER, date TIMESTAMP);"
sqlite3 results.db "CREATE TABLE IF NOT EXISTS weka_kmeans_text 
(id INTEGER PRIMARY KEY AUTOINCREMENT, documents INTEGER, k INTEGER, dimensions INTEGER, time INTEGER, date TIMESTAMP);"


doc_count=0
file=0

echo "linking min docs"
while ((doc_count<min_documents)); do
        #link files to the virtual dir
        ln -s $input_dir/$file $virtual_dir/text/$file
        ((file+=1))
        ((doc_count+=window))
done


for ((docs=min_documents; docs<=max_documents; docs+=documents_step)); do

echo "linking docs"
	#put the necessary input files to hdfs
	while ((doc_count<docs)); do
		((file+=1))
		((doc_count+=window))
		#link files to the virtual dir
		ln -s $input_dir/$file $virtual_dir/text/$file
	done
echo "converting to arff"

	#convert to arff
	$(dirname $0)/../weka/kmeans_text_weka/convert_text_weka.sh $virtual_dir &>$operator_out
	check $operator_out

	echo EXPERIMENT: weka tf-idf for $docs documents
	#tfidf
	start=$(date +"%s")
	$(dirname $0)/../weka/kmeans_text_weka/tfidf_text_weka.sh &>weka_kmeans_text.out
	features_no=$(tail weka_kmeans_text.out -n 1)
	echo $features_no
	time=$(( $(date +"%s")-start))
       	sqlite3 results.db "INSERT INTO weka_tfidf(documents, percentage, time, date)
            VALUES( $docs,  $features_no, $time, CURRENT_TIMESTAMP);"
																		

    for((k=min_k; k<=max_k; k+=k_step)); do
		echo "EXPERIMENT:  weka_kmeans_text for k=$k, $docs documents"
		#kmeans
    		start=$(date +"%s")
		$(dirname $0)/../weka/kmeans_text_weka/kmeans_text_weka.sh $k $max_iterations &>$operator_out
		check $operator_out
        	time=$(( $(date +"%s")-start))
       		sqlite3 results.db "INSERT INTO weka_kmeans_text(documents, k, time, date, dimensions)
            		VALUES( $docs,  $k, $time, CURRENT_TIMESTAMP, $features_no);"
																		
	done
done

exit
	

rm -rf tmp 2>/dev/null
