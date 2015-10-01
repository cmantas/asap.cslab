#!/bin/bash
source  $(dirname $0)/config.info       #loads the parameters
source  $(dirname $0)/common.sh         #loads the common functions

tmp_input=./tmp_text/
local_input=/root/Data/ElasticSearch_text_docs

sqlite3 vic_results.db "CREATE TABLE IF NOT EXISTS word2vec_gensim 
	(id INTEGER PRIMARY KEY AUTOINCREMENT, 
	 documents INTEGER, 
	 execTime REAL,
	 minDf INTEGER, 
         input_size INTEGER,
	 vector_size INTEGER,
	 metrics TEXT, 
	 date DATE DEFAULT (datetime('now','localtime')));"

for ((docs=100; docs<=100000; docs+=2000)); do

	printf "\n\nMoving $docs documents to $tmp_input...\n\n"
	./move_local.sh $local_input $tmp_input $docs >/dev/null;
	
	input_size=$(du -h -b $tmp_input | cut -f1)
	vector_size=100
	minDf=5

	tstart; monitor_start
	asap word2vec gensim $tmp_input $vector_size $minDf
	sleep 2
	execTime=$(ttime); metrics=$(monitor_stop)
	
	sqlite3 vic_results.db "INSERT INTO word2vec_gensim (documents, execTime, input_size, vector_size, minDf, metrics) 
			VALUES ('$docs', '$execTime', '$input_size', '$vector_size', '$minDf', '$metrics' );"
	rm -rf $tmp_input
done
