


input=$1
K=$2
max_iterations=$3
WORK_DIR="/tmp/mahout_kmeans"

check (){
        e=$( cat $1 | grep -E "Exception|ERROR: " )
        t=$( echo $e | wc -c)
        if [ "$e" != "" ]; then
                echo $e
                exit
        fi
}

