source $(dirname $0)/common.sh


echo "[STEP 2/4] Sequence to Sparse"
~/Code/mahout-master/bin/mahout seq2sparse \
    -i ${WORK_DIR}/sequence_files --chunkSize $chunk\
    -o ${WORK_DIR}/sparce_matrix_files --maxDFPercent 85 --namedVector \
	-Dmapred.child.ulimit=15728640 -Dmapred.child.java.opts=-Xmx5g \
	-Dmapred.map.tasks=4 \
	&>step2.out
check step2.out

#+UseConcMarkSweepGC
#       -Dmapred.map.child.java.opts=-Xmxg4g \
#       -Dmapred.reduce.child.java.opts=-Xmx4g \

