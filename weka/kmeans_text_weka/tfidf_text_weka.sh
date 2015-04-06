source $(dirname $0)/common.sh
min_frequency=10


echo "STEP 2/3: TF/IDF"
java -Xmx15g -cp ${WEKA} weka.filters.unsupervised.attribute.StringToWordVector \
	     -N 0 \
	     -W 100 \
	     -prune-rate -1.0 \
	     -stemmer weka.core.stemmers.NullStemmer \
	     -M ${min_frequency} \
	     -tokenizer "weka.core.tokenizers.WordTokenizer \
	     -delimiters \" \\r\\n\\t.,;:\\\'\\\"()?\!\"" \
	     -i ${WD}/data.arff \
	     -S -L -C\
	     -o ${WD}/tf_idf_data.arff

fvl=$(cat ${WD}/tf_idf_data.arff | grep @attribute | wc -l)
(( fvl=fvl-1 ))

echo Number of features:
echo $fvl
