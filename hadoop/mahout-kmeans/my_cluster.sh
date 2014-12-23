
output=tmp/reuters-text
input=input

WORK_DIR=tmp


echo "creating work directory at ${WORK_DIR}"
rm -rf $WORK_DIR; mkdir -p ${WORK_DIR}/reuters-sgm

check (){
	e=$( cat $1 | grep Exception)
	t=$( echo $e | wc -c)
	if [ "$e" != "" ]; then
		echo $e
		exit
	fi
}


echo Extracting
mkdir -p $input/reuters-sgm; tar xzf reuters21578.tar.gz -C $input/reuters-sgm

echo "[STEP 1.1/4] Extracting Reuters with Lucene"
mahout org.apache.lucene.benchmark.utils.ExtractReuters ${input}/reuters-sgm ${output} &>step1.out