source $(dirname $0)/common.sh

PARSER_JAR=~/bin/lib/CSV2Seq.jar


echo "[STEP 0/2] CSVs to Sequence File"
hadoop jar ${PARSER_JAR} ${input} ${WORK_DIR}/my_synthetic_seq

#DNK if it is needed but does not work
# echo "[STEP   2/4] Sequence to Sparse"
#  mahout seq2sparse \
#     -i ${WORK_DIR}/synth_sequence_files \
#     -o ${WORK_DIR}/synth_sparce_matrix --maxDFPercent 85 --namedVector 

echo "[STEP 1/2] K-Means"
  mahout kmeans \
    -i ${WORK_DIR}/my_synthetic_seq \
    -c ${WORK_DIR}/what_is_this \
    -o ${WORK_DIR}/clustering_raw_output\
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
    -x ${max_iterations} -k ${K} -ow --clustering  &>step1.out
check step3.out

echo "[STEP 2/2] Clusterdump"
  mahout clusterdump \
    -i ${WORK_DIR}/clustering_raw_output/clusters-*-final \
    -o ${WORK_DIR}/clusterdump_result \
    -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 \
    --pointsDir ${WORK_DIR}/clustering_raw_output/clusteredPoints &>step2.out


echo "[RESULT ]"

head ${WORK_DIR}/clusterdump_result

rm -r ${WORK_DIR}
rm step*.out
