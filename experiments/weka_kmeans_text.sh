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
        for((clusters=min_clusters; clusters<=max_clusters; clusters+=clusters_step)); do
		file=$(((docs-documents_step)/documents_step))
		
		
		#link files to the virtual dir
		ln -s $input_dir/$file $virtual_dir/text/$file
		EXPERIMENT_NAME="weka_kmeans_text: documents $docs, K $clusters"
		OPERATOR_OUTPUT=$operator_out
		EXPERIMENT_OUTPUT=$results_file		
		experiment  $(dirname $0)/../weka/kmeans_text_weka/kmeans_text_weka.sh $virtual_dir $clusters $max_iterations
		echo $(dirname $0)/../weka/kmeans_text_weka/kmeans_text_weka.sh $virtual_dir $clusters $max_iterations
	
		check $operator_out
	done
done

exit
	

rm -rf tmp 2>/dev/null
