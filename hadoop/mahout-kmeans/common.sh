chunk=30
TOOLS_JAR="/home/$USER/bin/lib/asapTools.jar"

check (){
        e=$( cat $1 | grep -E "Exception|ERROR: " )
        t=$( echo $e | wc -c)
        if [ "$e" != "" ]; then
                echo $e
                exit
        fi
}

