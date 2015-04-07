source $(dirname $0)/common.sh

minTF=20

input=$1
output=$2
maxDFpercent=$3

echo "[STEP 2/4] Sequence to Sparse KOKOKOO $input, $output"
 mahout seq2sparse \
    -i $1 --chunkSize $chunk\
    -o $2 --maxDFPercent $maxDFpercent --namedVector --minSupport $minTF\
	-Dmapred.child.ulimit=15728640 -Dmapred.child.java.opts=-Xmx5g \
	-Dmapred.map.tasks=4 \
	&>step2.out
check step2.out

#+UseConcMarkSweepGC
#       -Dmapred.map.child.java.opts=-Xmxg4g \
#       -Dmapred.reduce.child.java.opts=-Xmx4g \

