#!/bin/bash

experiment () {
	if [[ -z $exp_name ]]; then exp_name="Unnamed Experiment"; fi;
	if [[ -z $OPERATOR_OUTPUT ]]; then OPERATOR_OUTPUT="/dev/null/"; fi;
	if [[ -z $EXPERIMENT_OUTPUT ]]; then EXPERIMENT_OUTPUT="experiment_results.info"; fi;
	echo "[EXPERIMENT] $exp_name"
	out=/dev/null  
	
	date1=$(date +"%s")
       	$@ &>>$OPERATOR_OUTPUT
	date2=$(date +"%s")
       	diff=$(($date2-$date1))

	echo $exp_name, $diff sec >>$EXPERIMENT_OUTPUT
	
	#reset variables
	exp_name=""
	OPERATOR_OUTPUT=""
	EXPERIMENT_OUTPUT=""


}



