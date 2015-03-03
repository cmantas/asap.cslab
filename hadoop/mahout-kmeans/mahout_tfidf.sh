source $(dirname $0)/common.sh


echo "[STEP 2/4] Sequence to Sparse"
 mahout seq2sparse \
    -i ${WORK_DIR}/sequence_files \
    -o ${WORK_DIR}/sparce_matrix_files --maxDFPercent 85 --namedVector &>step2.out
check step2.out

