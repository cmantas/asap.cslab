if [[ $# != 3 ]]; then
    echo Expected parameters: Input, K, iterations
    exit
fi

input=$1
K=$2
max_iterations=$3

WORK_DIR=tmp


echo "creating work directory at ${WORK_DIR}"
rm -rf $WORK_DIR; mkdir -p ${WORK_DIR}

check (){
	e=$( cat $1 | grep Exception)
	t=$( echo $e | wc -c)
	if [ "$e" != "" ]; then
		echo $e
		exit
	fi
}



echo "[STEP 1/4] Converting to Sequence Files from Directory"
mahout seqdirectory -i ${input} -o ${WORK_DIR}/sequence_files -c UTF-8 -chunk 64 -xm sequential &>step1.out
check step1.out


echo "[STEP 2/4] Sequence to Sparse"
 mahout seq2sparse \
    -i ${WORK_DIR}/sequence_files \
    -o ${WORK_DIR}/sparce_matrix_files --maxDFPercent 85 --namedVector &>step2.out
check step2.out

echo "[STEP 3/4] K-Means"
  mahout kmeans \
    -i ${WORK_DIR}/sparce_matrix_files/tfidf-vectors/ \
    -c ${WORK_DIR}/what_is_this \
    -o ${WORK_DIR}/clustering_raw_output\
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
    -x ${max_iterations} \
    -k ${K} \
    -ow --clustering  &>step3.out
check step3.out

echo "[STEP 4/4] Clusterdump"
  mahout clusterdump \
    -i ${WORK_DIR}/clustering_raw_output/clusters-*-final \
    -o ${WORK_DIR}/clusterdump_result \
    -d ${WORK_DIR}/sparce_matrix_files/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 \
    --pointsDir ${WORK_DIR}/clustering_raw_output/clusteredPoints &>step4.out
check step4.out

echo "[RESULT  ]"
 head ${WORK_DIR}/clusterdump_result
