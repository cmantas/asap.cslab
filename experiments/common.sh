####check function###
function check {
        e=$( cat $1 | grep -E "Exception|ERROR:" )
        if [ "$e" != "" ]; then
	        echo $e
	        exit
	fi
}

check_spark(){
	ok=$(cat $1|grep "\-\-OK\-\-"|wc -l)
	if [ $ok -eq 0 ] ;
	then
	echo Experiment Failed
	exit;  fi
}


### Timer functions ###
function tstart {
	        start=$(date +%s%N | cut -b1-13)
}


function ttime  {
        now=$(date +%s%N | cut -b1-13)
        echo $(( now-start ))
}

## Monitoring Functions

monitor_start(){
         #start monitoring
         asap monitor -f monitoring_data.txt &
         export mpid=$!
}

monitor_stop(){
        # retreive the monitoring metrics
        kill $mpid
        metrics=$(cat monitoring_data.txt)
        rm monitoring_data.txt
        echo "$metrics"
}

size(){
	ls -l $1 | awk '{print $5}'
}

hdfs_size(){
	hdfs dfs -du -s $1 | awk '{print $1}'
}
