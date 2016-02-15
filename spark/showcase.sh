#!/usr/bin/env bash

csv_dataset=$1 # the input dataset
category=1 # the category to use
work_dir=/tmp/imr_logistic_regression
w2v_jar_path=./imr_w2v_2.11-1.0.jar

categories=$work_dir/labels_$category.csv
## TODO ###
w2v_model=~/Data/w2v_model_spark

w2v_output=~/Data/imr_sample/ # the output of the W2V vectorization
class_output=$work_dir/classification_output

model=$work_dir/lr_model.csv # the logistic regression model csv


# create/clean up dirs, etc
rm -r $work_dir &>/dev/null
mkdir -p $work_dir


### PREPROCESS ###
# create a csv of all available labels 
#(showcase only: this should be done offline)
cat $csv_dataset  | awk  -F ';'  "{print \$$((category +1))}"  |  \
	uniq | tr '\n' ',' \
	> $categories

spark-submit $w2v_jar_path sm $csv_dataset $w2v_model
spark-submit $w2v_jar_path sv $w2v_model $csv_dataset $w2v_output

###  TRAIN CLASSIFIER  ###
# create an initial model 
python imr_classification.py train $w2v_output \
	--model  $model \
	--labels $categories \
	--category $category \
	--evaluate #flag for cross-evaluation on 20% of the data

# update a previous model 
python imr_classification.py train $w2v_output \
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
 python imr_classification.py classify $work_dir/mock.csv\
        --output $class_output \
        --model  $model \
        --labels $categories 

echo "================> Results <====================="
printf "Original Labels: \n	"
head -n $mock_count  $csv_dataset  | awk  -F ';'  "{print \$$((category +1))}" | tr '\n' ','

printf "\n\nClassified Labels: \n	"
cat $class_output/* | head -n $mock_count | awk -F '[(,]'   '{print $2}' | tr '\n' ',' 

