source $(dirname $0)/common.sh
min_frequency=50


echo "STEP 2/3: TF/IDF"
java -Xmx15g -cp ${WEKA} weka.filters.unsupervised.attribute.StringToWordVector \
	     -R first-last -C -L -N 0 \
	     -W 99999999 \
	     -prune-rate -1.0 \
	     -stemmer weka.core.stemmers.NullStemmer \
	     -M ${min_frequency} \
	     -tokenizer "weka.core.tokenizers.WordTokenizer \
	     -delimiters \" \\r\\n\\t.,;:\\\'\\\"()?\!\"" \
	     -i ${WD}/data.arff \
	     -o ${WD}/tf_idf_data.arff
