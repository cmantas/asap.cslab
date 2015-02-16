input=/mnt/DataDisk/Datasets/ElasticSearch_text_docs/
output=""
iterations=10
clusters=5

min_frequency=10

WEKA=../weka.jar
WD=/tmp/kmeans_text_weka
mkdir -p $WD


echo "STEP 1/3: Text to arff"
java -cp ${WEKA} weka.core.converters.TextDirectoryLoader \
	     -dir ${input}\
	     > ${WD}/data.arff

echo "STEP 2/3: TF/IDF"
java -cp ${WEKA} weka.filters.unsupervised.attribute.StringToWordVector \
	     -R first-last -C -L -N 0 \
	     -W 99999999 \
	     -prune-rate -1.0 \
	     -stemmer weka.core.stemmers.NullStemmer \
	     -M ${min_frequency} \
	     -tokenizer "weka.core.tokenizers.WordTokenizer \
	     -delimiters \" \\r\\n\\t.,;:\\\'\\\"()?\!\"" \
	     -i ${WD}/data.arff \
	     -o ${WD}/tf_idf_data.arff

echo "STEP 1/3: K-Means"
if [ $output ];then
	output=${ouput}/clusters.txt
else
	output=clusters.txt
fi

java -cp ${WEKA} weka.clusterers.SimpleKMeans \
	     -N ${clusters} \
	     -I ${iterations}  \
	     -A "weka.core.EuclideanDistance -R first-last" \
	     -t ${WD}/tf_idf_data.arff \
	     > ${output}



#rm -r $WD
