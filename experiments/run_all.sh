# first generate the synth clusters
./generate_synth_clusters.sh

#run the synth clusters experiments on weka
./weka_kmeans_synth.sh 
#and on mahout
./mahout_kmeans_synth.sh

#load the docs from elasticSearch
./elasticsearch_load_documents.sh  

#run the text experiments on weka
./weka_kmeans_text.sh
#and on mahout
./mahout_kmeans_text.sh
