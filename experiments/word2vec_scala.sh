#!/bin/bash
source  $(dirname $0)/config.info       #loads the parameters
source  $(dirname $0)/common.sh         #loads the common functions

hadoop_input=hdfs://master:9000/user/root/exp_text
local_input=/root/Data/ElasticSearch_text_docs

sqlite3 vic_results.db "CREATE TABLE IF NOT EXISTS word2vec_scala 
	(id INTEGER PRIMARY KEY AUTOINCREMENT, 
	 documents INTEGER, execTime REAL, 
         input_size INTEGER,
	 minDf INTEGER,
	 iterations INTEGER,
	 vector_size INTEGER,
	 metrics TEXT, 
	 date DATE DEFAULT (datetime('now','localtime')));"

for ((docs=500; docs<=10000; docs+=500)); do

	hdfs dfs -rm -r $hadoop_input &>/dev/null
	printf "\n\nMoving data to hdfs...\n\n"
	asap move dir2sequence $local_input $hadoop_input $docs &> dir2sequence.out
	printf "\n\nDocs: $docs\n\n"

	input_size=$(hdfs_size $hadoop_input)
	vector_size=100
	minDf=5
	iterations=1

	tstart; monitor_start
	#echo Running Spark Word2Vec with k $k
	asap word2vec spark_scala $hadoop_input
	sleep 2
	execTime=$(ttime); metrics=$(monitor_stop)
	
	sqlite3 vic_results.db "INSERT INTO word2vec_scala (documents, execTime, input_size, minDf, iterations, vector_size, metrics) 
			VALUES ('$docs', '$execTime', '$input_size', '$minDf', '$iterations', '$vector_size','$metrics' );"
done
