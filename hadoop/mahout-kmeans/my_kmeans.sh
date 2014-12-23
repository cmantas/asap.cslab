
WORK_DIR=tmp
input=tmp/reuters-text

check (){
    e=$( cat $1 | grep Exception)
    t=$( echo $e | wc -c)
    if [ "$e" != "" ]; then
        echo $e
        exit
    fi
}


echo "[STEP 1.2/4] Converting to Sequence Files from Directory"
mahout seqdirectory -i ${input} -o ${WORK_DIR}/seqdir -c UTF-8 -chunk 64 -xm sequential &>step1.out
check step1.out




echo "[STEP 2/4] Sequence to Sparse"
 mahout seq2sparse \
    -i ${WORK_DIR}/seqdir/ \
    -o ${WORK_DIR}/sparse --maxDFPercent 85 --namedVector &>step2.out
check step2.out

echo "[STEP 3/4] K-Means"
  mahout kmeans \
    -i ${WORK_DIR}/sparse/tfidf-vectors/ \
    -c ${WORK_DIR}/my-ls \
    -o ${WORK_DIR}/kmeans \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
    -x 10 -k 20 -ow --clustering  &>step3.out
check step3.out

echo "[STEP 4/4] Clusterdump"
  mahout clusterdump \
    -i ${WORK_DIR}/kmeans/clusters-*-final \
    -o ${WORK_DIR}/kmeans/clusterdump \
    -d ${WORK_DIR}/sparse/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 \
    --pointsDir ${WORK_DIR}/kmeans/clusteredPoints &>step4.out
check step4.out

 echo "[RESULT]"
 head ${WORK_DIR}/kmeans/clusterdump