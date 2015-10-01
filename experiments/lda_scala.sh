#!/bin/bash
source  $(dirname $0)/config.info       #loads the parameters
source  $(dirname $0)/common.sh         #loads the common functions

hadoop_input=hdfs://master:9000/user/root/exp_text
local_input=/root/Data/ElasticSearch_text_docs

sqlite3 vic_results.db "CREATE TABLE IF NOT EXISTS lda_scala2 
	(id INTEGER PRIMARY KEY AUTOINCREMENT, 
	 documents INTEGER, 
	 execTime REAL, 
         input_size INTEGER,
	 k INTEGER,
	 maxIterations INTEGER,
	 metrics TEXT, 
	 date DATE DEFAULT (datetime('now','localtime')));"

for ((docs=1000; docs<=20000; docs+=500)); do

	hdfs dfs -rm -r $hadoop_input &>/dev/null
	printf "\n\nMoving $docs documents to hdfs...\n\n"
	asap move dir2sequence $local_input $hadoop_input $docs &> dir2sequence.out
	#printf "\n\nDocs: $docs\n\n"
	printf "\n\nTFIDF\n\n"
	asap tfidf spark /user/root/exp_text /user/root/exp_text/tfidf 5
	
	input_size=$(hdfs_size $hadoop_input)
	iterations=1
	k=10

	tstart; monitor_start
	#echo Running Spark Word2Vec with k $k
	asap lda scala "$hadoop_input/tfidf/part*"
	sleep 2
	execTime=$(ttime); metrics=$(monitor_stop)
	
	sqlite3 vic_results.db "INSERT INTO lda_scala2 (documents, execTime, input_size, maxIterations, k, metrics) 
			VALUES ('$docs', '$execTime', '$input_size', '$iterations','$k','$metrics' );"
done
