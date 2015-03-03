source $(dirname $0)/common.sh

echo $input
echo "[STEP 1/4] Converting to Sequence Files from Directory"
mahout seqdirectory -i ${input} -o ${WORK_DIR}/sequence_files -c UTF-8 -chunk 64 &>step1.out
check step1.out
