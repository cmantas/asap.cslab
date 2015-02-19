#!/bin/bash
source  $(dirname $0)/config.info 	#loads the parameters
source  $(dirname $0)/experiment.sh	#loads the experiment function


python ../elasticsearch/rest_loader.py total $max_documents window $window  output $documents_data_dir $proxy