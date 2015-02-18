if [[ $# != 3 ]]; then
        echo Expected parameters: Input, K, iterations
	exit
fi

input=$1
K=$2
max_iterations=$3
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

