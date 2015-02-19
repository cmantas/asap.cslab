#!/bin/bash

experiment () {
	if [[ -z $EXPERIMENT_NAME ]]; then EXPERIMENT_NAME="Unnamed Experiment"; fi;
	if [[ -z $OPERATOR_OUTPUT ]]; then OPERATOR_OUTPUT="/dev/null"; fi;
	if [[ -z $EXPERIMENT_OUTPUT ]]; then EXPERIMENT_OUTPUT="experiment.results"; fi;
	echo "[EXPERIMENT] $EXPERIMENT_NAME"
	out=/dev/null  
	
	date1=$(date +"%s")
       	$@ &>>$OPERATOR_OUTPUT
	date2=$(date +"%s")
       	diff=$(($date2-$date1))

	echo $EXPERIMENT_NAME, $diff sec >>$EXPERIMENT_OUTPUT
	
	#reset variables
	EXPERIMENT_NAME=""
	OPERATOR_OUTPUT=""
	EXPERIMENT_OUTPUT=""


}






