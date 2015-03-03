source $(dirname $0)/common.sh
input=$1

echo "STEP 1/3: Text to arff"
java -cp ${WEKA} weka.core.converters.TextDirectoryLoader \
	     -dir ${input}\
	     > ${WD}/data.arff

