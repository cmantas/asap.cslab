

MAHOUT="/usr/local/bin/mahout"
#algorithm=( kmeans fuzzykmeans lda streamingkmeans)
clustertype=kmeans

output=output
input=input

WORK_DIR=/tmp/mahout-work-${USER}


echo "creating work directory at ${WORK_DIR}"
mkdir -p ${WORK_DIR}/reuters-sgm

check (){
	e=$( cat $1 | grep Exception)
	t=$( echo $e | wc -c)
	if [ "$e" != "" ]; then
		echo $e
		exit
	fi
}

#?? check for what???
if [ "$HADOOP_HOME" != "" ] && [ "mahout_LOCAL" == "" ] ; then
  HADOOP="$HADOOP_HOME/bin/hadoop"
  if [ ! -e $HADOOP ]; then
    echo "Can't find hadoop in $HADOOP, exiting"
    exit 1
  fi
fi


echo Extracting
mkdir -p $input/reuters-sgm; tar xzf reuters21578.tar.gz -C $input/reuters-sgm

echo "[STEP 1.1/4] Extracting Reuters with Lucene"
mahout org.apache.lucene.benchmark.utils.ExtractReuters ${input}/reuters-sgm ${WORK_DIR}/reuters-out &>step1.out
echo "[STEP 1.2/4] Converting to Sequence Files from Directory"
mahout seqdirectory -i ${WORK_DIR}/reuters-out -o ${WORK_DIR}/reuters-out-seqdir -c UTF-8 -chunk 64 -xm sequential &>>step1.out
check step1.out




echo "[STEP 2/4] Sequence to Sparce"
 mahout seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans --maxDFPercent 85 --namedVector &>>step2.out
check step2.out

echo "[STEP 3/4] K-Means"
  mahout kmeans \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans/tfidf-vectors/ \
    -c ${WORK_DIR}/reuters-ls \
    -o ${WORK_DIR}/reuters-kmeans \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
    -x 10 -k 20 -ow --clustering  &>step3.out
check step3.out

echo "[STEP 4/4] Clusterdump"
  mahout clusterdump \
    -i ${WORK_DIR}/reuters-kmeans/clusters-*-final \
    -o ${output}/reuters-kmeans/clusterdump \
    -d ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 \
    --pointsDir ${WORK_DIR}/reuters-kmeans/clusteredPoints &>step4.out
check step4.out

 echo "[RESULT]"
 head ${WORK_DIR}/reuters-kmeans/clusterdump