source $(dirname $0)/common.sh

#workaround for a params problem
hv=$(hadoop version | grep Hadoop | awk  '{print $2}')
if [[ "$hv" > "2.5" ]]; then xmdummy="-xm sequential"; fi

mahout seqdirectory -i ${input} -o ${WORK_DIR}/sequence_files -c UTF-8 -chunk $chunk  $xmdummy -ow &>step1.out
check step1.out
