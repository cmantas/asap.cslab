data_file=~/Data/Result_W2V_IMR_medium.csv

ss_kmeans=$ASAP_HOME/spark/streaming/streaming_kmeans_kafka.py
k_producer=$ASAP_HOME/kafka/kafka_file_producer.py
monitor=$ASAP_HOME/monitoring/monitor.py

kill_ss(){
	kill $ss_pid # send kill sig
	# wait for process to finish
	while kill -0 $ss_pid 2>/dev/null; do
	    sleep 0.5
	done
}

k_produce(){
	bytes=$($k_producer -f $data_file -l $lines | grep chars | awk '{print $2}')
}

interval=3
k=2
lines=1000

# start spark streaming job and keep its id
spark-submit $ss_kmeans -i $interval -k $k &
ss_pid=$!; sleep 8 # wait for spark streaming to start

asap monitor start # start monitoring
k_produce # produce the kafka stream
echo Produced $bytes bytes

# wait for experiment to end and report streaming and monitoring metrics
asap report -cm -cs -e streaming_kmeans -m bytes=$bytes k=$k interval=$interval lines=$lines

kill_ss # kill the streaming job
echo OK DONE






