#!/bin/bash
source $(dirname $0)/common.sh

minTF=$3

input=$1
output=$2



echo "[STEP 2/4] Sequence to Sparse $input, $output, minTF=$minTF"
 mahout seq2sparse \
	-Dmapred.child.ulimit=15728640 -Dmapred.child.java.opts=-Xmx5g \
	-Dmapred.map.tasks=10 \
    -i $input -ow --chunkSize $chunk\
    -o $output --maxDFSigma 3.0  --namedVector --minSupport $minTF\
	&>step2.out
check step2.out

#+UseConcMarkSweepGC
#       -Dmapred.map.child.java.opts=-Xmxg4g \
#       -Dmapred.reduce.child.java.opts=-Xmx4g \

