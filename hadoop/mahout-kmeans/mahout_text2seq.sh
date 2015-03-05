source $(dirname $0)/common.sh
hdfs dfs -rm -r $WORK_DIR &>/dev/null; hdfs dfs -mkdir -p ${WORK_DIR}

mahout seqdirectory -i ${input} -o ${WORK_DIR}/sequence_files -c UTF-8 -chunk 64  -xm sequential - &>step1.out
check step1.out
