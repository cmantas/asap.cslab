#!/bin/bash
source  $(dirname $0)/config.info       #loads the parameters
source  $(dirname $0)/common.sh         #loads the common functions

tmp_input=./tmp_text
local_input=/root/Data/ElasticSearch_text_docs

sqlite3 vic_results.db "CREATE TABLE IF NOT EXISTS lda_gensim 
	(id INTEGER PRIMARY KEY AUTOINCREMENT, 
	 documents INTEGER, 
	 execTime REAL,
	 k INTEGER, 
         input_size INTEGER,
	 maxIterations INTEGER,
	 metrics TEXT, 
	 date DATE DEFAULT (datetime('now','localtime')));"

for ((docs=6000; docs<=50000; docs+=2000)); do

	printf "\n\nMoving $docs documents to $tmp_input...\n\n"
	./move_local.sh $local_input $tmp_input $docs >/dev/null;
	
	input_size=$(du -h -b $tmp_input | cut -f1)
	k=10
	iterations=1

	tstart; monitor_start
	asap lda gensim $tmp_input $k $iterations
	sleep 2
	execTime=$(ttime); metrics=$(monitor_stop)
	
	sqlite3 vic_results.db "INSERT INTO lda_gensim (documents, execTime, input_size, k, maxIterations, metrics) 
			VALUES ('$docs', '$execTime', '$input_size', '$k', '$iterations','$metrics' );"
	rm -rf $tmp_input
done
