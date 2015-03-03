#!/bin/bash

experiment () {
	if [[ -z $EXPERIMENT_NAME ]]; then EXPERIMENT_NAME="Unnamed Experiment"; fi;
	if [[ -z $OPERATOR_OUTPUT ]]; then OPERATOR_OUTPUT="/dev/null"; fi;
	if [[ -z $EXPERIMENT_OUTPUT ]]; then EXPERIMENT_OUTPUT="experiment.results"; fi;
	out=/dev/null  
	
	echo "[EXPERIMENT] $EXPERIMENT_NAME "
	date1=$(date +"%s")
       	$@ &>>$OPERATOR_OUTPUT
	date2=$(date +"%s")
       	diff=$(($date2-$date1))
	
	check $OPERATOR_OUTPUT

    	#write to file
	echo $EXPERIMENT_NAME, time $diff >>$EXPERIMENT_OUTPUT

	# write to sqlite
	table=$(echo $EXPERIMENT_NAME | awk '{ print $1}')
	table=${table%":"}
	data_name=$(echo $EXPERIMENT_NAME | awk '{ print $2}')
	data_value=$(echo $EXPERIMENT_NAME | awk '{print $3}')
	K=$(echo $EXPERIMENT_NAME | awk -vORS= '{ print $6}')
	K=${K%","}

	
	sqlite3 results.db "INSERT INTO $table($data_name, K, time, date)
	VALUES( $data_value, $K, $diff, CURRENT_TIMESTAMP);"
	#reset variables
	EXPERIMENT_NAME=""
	OPERATOR_OUTPUT=""
	EXPERIMENT_OUTPUT=""


}






