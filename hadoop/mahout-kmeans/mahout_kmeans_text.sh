source $(dirname $0)/common.sh

input=$1 #FIXME: use this as input
K=$2
max_iterations=$3

echo "[STEP 3/4] K-Means"
mahout kmeans \
	-i ${WORK_DIR}/sparce_matrix_files/tfidf-vectors/ \
	-c ${WORK_DIR}/what_is_this -o ${WORK_DIR}/clustering_raw_output \
	-dm org.apache.mahout.common.distance.CosineDistanceMeasure \
	-x ${max_iterations} \
	-k ${K}\
	-ow --clustering \
	-Dmapred.child.ulimit=15728640 -Dmapred.child.java.opts=-Xmx5g \
	-Dmapred.map.tasks=4 -Dmapred.max.split.size=$((chunk*1024*1024)) \
	&>step3.out 

check step3.out

#little hack - investigate further
final_clusters=$(hdfs dfs -ls ${WORK_DIR}/clustering_raw_output/ | grep final | awk '{print $8}')

echo "[STEP 4/4] Clusterdump"
  mahout clusterdump \
    -i ${final_clusters} \
    -o clusterdump_result \
    -d ${WORK_DIR}/sparce_matrix_files/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 \
    --pointsDir ${WORK_DIR}/clustering_raw_output/clusteredPoints &>step4.out
check step4.out

echo "[RESULT  ]"
 head clusterdump_result
 rm clusterdump_result
