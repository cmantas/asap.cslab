chunk=30
WORK_DIR="/tmp/mahout_kmeans"

check (){
        e=$( cat $1 | grep -E "Exception|ERROR: " )
        t=$( echo $e | wc -c)
        if [ "$e" != "" ]; then
                echo $e
                exit
        fi
}

