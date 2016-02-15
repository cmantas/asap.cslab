#!/usr/bin/env bash

csv_dataset=$1 # the input dataset

category=1 # the category to use
# a csv file with the all thepossible category labels of this categoyr
categories=labels_$category.csv 

work_dir=hdfs://master:9000/tmp/imr_workflow # dir of intermediate/output data

w2v_jar_path=~/bin/lib/imr_w2v_2.11-1.0.jar # path for the w2v jar file

w2v_model=$work_dir/w2v_model_spark # the dir where the w2v model will be saved
w2v_output=$work_dir/imr_sample/ # the output vectors of w2v

model=$work_dir/lr_model.csv # the logistic regression model (csv)
class_output=$work_dir/classification_output # the output of the classification


# create/clean up dirs, etc
rm -r $work_dir &>/dev/null; mkdir -p $work_dir # empty work dir
hdfs dfs -rm -r $w2v_model # delete previous w2v model


### TRAIN W2V ###
spark-submit $w2v_jar_path sm $csv_dataset $w2v_model

### Vectorize with W2V ###
spark-submit $w2v_jar_path sv $w2v_model $csv_dataset $w2v_output

###  TRAIN CLASSIFIER  ###
# create an initial model 
spark-submit imr_classification.py train $w2v_output \
	--model  $model \
	--labels $categories \
	--category $category \
	--evaluate #flag for cross-evaluation on 20% of the data

# update a previous model 
spark-submit imr_classification.py train $w2v_output \
	--model  $model \
	--labels $categories \
	--category $category \
	--update # flag for loading an updating a model

## create a mock dataset for classificaton, having only the features, not the labels
mock_count=10
cat $w2v_output/* | head -n $mock_count | grep -o "\[.*\]" > $work_dir/mock.csv
rm -r $class_output 2>/dev/null

#### CLASSIFY ######

# classify based on this model
 spark-submit imr_classification.py classify $work_dir/mock.csv\
        --output $class_output \
        --model  $model \
        --labels $categories 

echo "================> Results <====================="
printf "Original Labels: \n	"
head -n $mock_count  $csv_dataset  | awk  -F ';'  "{print \$$((category +1))}" | tr '\n' ','

printf "\n\nClassified Labels: \n	"
cat $class_output/* | head -n $mock_count | awk -F '[(,]'   '{print $2}' | tr '\n' ',' 

