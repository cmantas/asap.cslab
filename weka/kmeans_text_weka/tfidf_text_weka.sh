source $(dirname $0)/common.sh
min_frequency=$2

max_features=$1


echo "STEP 2/3: TF/IDF"
java -Xmx15g -cp ${WEKA} weka.filters.unsupervised.attribute.StringToWordVector \
	     -N 0 \
	     -W $max_features \
	     -prune-rate -1.0 \
	     -stemmer weka.core.stemmers.NullStemmer \
	     -M ${min_frequency} \
             -tokenizer "weka.core.tokenizers.WordTokenizer \
	                  -delimiters \" \\r\\n\\t.,;:\\\'\\\"()?\!\$#-0123456789/*%<>@[]+\`~_=&^   \"" \
	     -i ${WD}/data.arff \
	     -L -S -I -C \
	     -o ${WD}/tf_idf_data.arff

fvl=$(cat ${WD}/tf_idf_data.arff | grep @attribute | wc -l)
(( fvl=fvl-1 ))

echo Number of features:
echo $fvl
