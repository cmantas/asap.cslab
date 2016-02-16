#!/usr/bin/env bash

csv_dataset=$1 # the input csv_dataset (an hdfs url)
category=1 # the category to use
categories=labels.json  # a json file holding all possible labels for each category


##############  intermediate  data #########################3###
work_dir=$(dirname $csv_dataset)/intermediate # dir of intermediate/output data
w2v_jar_path=~/bin/lib/imr_w2v_2.11-1.0.jar # path for the w2v jar file

w2v_model=$work_dir/w2v_model_spark # the dir where the w2v model will be saved
				    # for now, it is stored in hdfs only
w2v_output=$work_dir/imr_sample/ # the output vectors of w2v

lr_model=$work_dir/lr_model # the logistic regression model (hdfs)

class_output=$work_dir/classification_output # the output of the classification


# create/clean up dirs, etc
#rm -r $work_dir &>/dev/null; mkdir -p $work_dir # empty work dir
hdfs dfs -rm -r $w2v_model # delete previous w2v model


### TRAIN W2V ###
spark-submit $w2v_jar_path sm $csv_dataset $w2v_model

### Vectorize with W2V ###
spark-submit $w2v_jar_path sv $w2v_model $csv_dataset $w2v_output

###  TRAIN CLASSIFIER  ###
 create an initial model 
spark-submit --py-files imr_tools.py, \
	imr_classification.py train $w2v_output \
	--model  $lr_model \
	--labels $categories \
	--category $category \
	--evaluate \
 --evaluate is a flag for 20% cross-eval with training input

# update a previous model 
spark-submit --py-files imr_tools.py imr_classification.py train $w2v_output \
	--model  $lr_model\
	--labels $categories \
	--category $category \
	--update # flag for loading an updating a model
# create a mock dataset for classificaton, having only the features, not the labels

#### CLASSIFY ######

# classify based on this model
 spark-submit --py-files imr_tools.py imr_classification.py classify $w2v_output \
        --output $class_output \
        --model  $lr_model \
        --labels $categories 


#echo "================> Results <====================="
#printf "Original Labels: \n	"
#hdfs dfs -cat $csv_dataset | head -n 10 | awk  -F ';'  "{print \$$((category +1))}" | tr '\n' ','
#
#printf "\n\nClassified Labels: \n	"
#hdfs dfs -cat $class_output/* | head -n 10 | awk -F '[(,]'   '{print $2}' | tr '\n' ',' 

