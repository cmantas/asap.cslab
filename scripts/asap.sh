#!/bin/bash 

# libraries, etc
tools="$HOME/bin/lib/asapTools.jar"

export CHUNK=30
SPARK_MASTER=$(cat /etc/hosts | grep master | awk '{print $1}')
SPARK_PORT=7077

#--executor-memory 6g
spark="spark-submit --master spark://$SPARK_MASTER:$SPARK_PORT "
echo hello

function kmeans #ENGINE K MAX_ITERATIONS 
{
engine=$1
shift
case "$engine" in
 	spark)
		$spark ${ASAP_HOME}/spark/spark_kmeans_text.py -i $1 -k $2 -mi $3;;
	weka)
		${ASAP_HOME}/weka/kmeans_text_weka/kmeans_text_weka.sh $@ ;;
	mahout)
		${ASAP_HOME}/hadoop/mahout-kmeans/mahout_kmeans_text.sh $@ ;;
esac

}

function tfidf #ENGINE INPUT OUTPUT MIN_DOCS  
{
	engine=$1
	shift
	case "$engine" in
	 	spark)
			echo tfidf in spark
			$spark ${ASAP_HOME}/spark/spark_tfidf.py -i $1 -o $2 -mdf $3;;
		weka)
			echo tfidf in weka
			${ASAP_HOME}/weka/kmeans_text_weka/tfidf_weka.sh $@ ;;
		mahout)
			echo tfidf in  mahout
			${ASAP_HOME}/hadoop/mahout-kmeans/mahout_tfidf.sh	$@ ;;
	esac

}

function move # MOVE_OPERATION INPUT OUTPUT [COUNT]
{
	operation=$1
	shift
	case "$operation" in
		dir2arff)
			${ASAP_HOME}/weka/kmeans_text_weka/convert_text_weka.sh $@ ;;
		dir2sequence)
			hadoop jar $tools loadDir $@ $CHUNK ;;
		dir2spark)
			pyspark ${ASAP_HOME}/spark/text_loader.py -i $1 -do $2 ;;
		arff2mahout)
			hadoop jar $tools arff2mahout $@ ;;
		mahout2arff)
			hadoop jar $tools mahout2arff $@ ;;
		mahout2spark)
			hadoop jar $tools mahout2spark $@ ;;
		*)
			echo No such mover ;;
	esac

}

function help  # Show a list of available opperations
{

	echo ======--- Available Commands ---======
	grep "^function" $0 | sed "s/function/➜/g" 
}

if [ "_$1" = "_" ]; then
    help
else
        "$@"
fi
