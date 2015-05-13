#!/bin/bash 

ASAP_HOME="dummy"
# libraries, etc
asap_tools="/home/cmantas/bin/lib/asapTools.jar"

function weka_kmeans_text 
{
 echo "my function";
 ${ASAP_HOME}/weka/kmeans_text_weka/kmeans_text_weka.sh
}

function ata # hello
{
	echo ata function
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
