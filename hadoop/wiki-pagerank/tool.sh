input="Data/all"
output="Data/output"
driver="Main"


build(){
	mvn clean package | grep ERROR

}

run () {
#rm -rf $output
	#run a MR job
	echo M-R task START
	date1=$(date +"%s")
	hadoop jar target/*.jar $driver $input $output &>run.out 
	cat run.out | grep Exception

	date2=$(date +"%s")
	diff=$(($date2-$date1))
	echo "task took $diff sec. Output/Error in 'run.out'"
}

show () {
	echo RESULT: \n
	head $output/part*
}



############### MAIN  ########################

if (( $#==0 )); then
	echo targets: run, show
 	run; show
fi

for var in "$@"
do
    echo "Running: $var"
    eval $var
done
