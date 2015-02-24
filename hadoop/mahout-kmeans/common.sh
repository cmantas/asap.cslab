if [[ $# != 3 ]]; then
        echo [KMEANS] Expected parameters: Input, K, iterations
	exit
fi

input=$1
K=$2
max_iterations=$3
WORK_DIR=/tmp/mahout_kmeans
echo "creating work directory at ${WORK_DIR}"
hdfs dfs -rm -r $WORK_DIR &>/dev/null; hdfs dfs -mkdir -p ${WORK_DIR}

check (){
        e=$( cat $1 | grep -E "Exception|ERROR" )
        t=$( echo $e | wc -c)
        if [ "$e" != "" ]; then
                echo $e
                exit
        fi
}

