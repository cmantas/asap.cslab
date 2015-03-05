#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/experiment.sh	#loads the experiment function
results_file="results/weka_kmeans_text_experiments.results"
operator_out="weka_kmeans_text.out"
rm $operator_out &>/dev/null


input_dir=~/Data/ElasticSearch_text_docs
virtual_dir=~/Data/docs_virt_dir
rm -rf $virtual_dir 2>/dev/null
mkdir -p $virtual_dir/text

for ((docs=documents_step; docs<=max_documents; docs+=documents_step)); do

	#put the necessary input files to hdfs
	while ((doc_count<docs)); do
		((file+=1))
		((doc_count+=window))
		#link files to the virtual dir
		ln -s $input_dir/$file $virtual_dir/text/$file
	done

	#convert to arff
	$(dirname $0)/../weka/kmeans_text_weka/convert_text_weka.sh $virtual_dir >/dev/null

	#tfidf
	EXPERIMENT_NAME="weka_tfidf: documents $docs , K 0"
	OPERATOR_OUTPUT=$operator_out
	EXPERIMENT_OUTPUT=$results_file		
	experiment $(dirname $0)/../weka/kmeans_text_weka/tfidf_text_weka.sh
	check $operator_out

    for((clusters=min_clusters; clusters<=max_clusters; clusters+=clusters_step)); do

		#kmeans
		EXPERIMENT_NAME="weka_kmeans_text: documents $docs , K $clusters"
		OPERATOR_OUTPUT=$operator_out
		EXPERIMENT_OUTPUT=$results_file		
		experiment $(dirname $0)/../weka/kmeans_text_weka/kmeans_text_weka.sh $clusters $max_iterations
		check $operator_out
	done
done

exit
	

rm -rf tmp 2>/dev/null
