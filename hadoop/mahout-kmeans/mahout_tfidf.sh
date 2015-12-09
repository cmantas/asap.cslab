#!/bin/bash
# "." command is like source (I guess)
. $(dirname $0)/common.sh

minTF=$3

input=$1
output=$2



echo "[STEP 2/4] Sequence to Sparse $input, $output, minTF=$minTF"
mahout seq2sparse $tfidf_env    -i $input -ow --chunkSize $chunk\
    -o $output --maxDFSigma 3.0  --namedVector --minSupport $minTF
#	&>step2.out

exit_status=$?
#check step2.out


exit $exit_status

#+UseConcMarkSweepGC
#       -Dmapred.map.child.java.opts=-Xmxg4g \
#       -Dmapred.reduce.child.java.opts=-Xmx4g \

