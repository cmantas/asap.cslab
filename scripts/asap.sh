#!/bin/bash 

# libraries, etc
tools="/home/cmantas/bin/lib/asapTools.jar"

export CHUNK=30


function kmeans #ENGINE K MAX_ITERATIONS 
{
engine=$1
shift
case "$engine" in
 	spark)
		echo hello spark;;
	weka)
		${ASAP_HOME}/weka/kmeans_text_weka/kmeans_text_weka.sh $@ ;;
	mahout)
		echo kmeans in  mahout
		${ASAP_HOME}/hadoop/mahout-kmeans/mahout_kmeans_text.sh $@ ;;
esac

}

function tfidf #ENGINE INPUT OUTPUT MIN_DOCS  
{
	engine=$1
	shift
	case "$engine" in
	 	spark)
			echo hello spark ;;
		weka)
			echo tfidf in weka
			${ASAP_HOME}/weka/kmeans_text_weka/tfidf_weka.sh $@ ;;
		mahout)
			echo kmeans in  mahout
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
		arff2mahout)
			hadoop jar $tools arff2mahout $@ ;;
		mahout2arff)
			hadoop jar $tools mahout2arff $@ ;;
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
