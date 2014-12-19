hadoop_dir="/etc/hadoop"
# DFS 
echo "STARTED test"
echo "TTTTTTTT  starting test  TTTTTTTTT" &>test.out
hdfs dfs -mkdir /user &>>test.out
hdfs dfs -mkdir /user/$USERNAME &>>test.out

#create a dummy file
echo "troll troll troll trollolo dummy dummy">dummy.tmp

#put it do dfs
hdfs dfs -mkdir /user/$USERNAME/input &>>test.out
hdfs dfs -put dummy.tmp input/ &>>test.out
rm dummy.tmp

#delete output from prev runs
hdfs dfs -rm -r output &>>test.out

#run a MR job
echo STARTED M-R task
echo "TTTTTTTT  starting M-R  TTTTTTTTT" >>test.out
date1=$(date +"%s")
hadoop jar $hadoop_dir/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.*.jar grep input output 'troll' &>>test.out 

date2=$(date +"%s")
diff=$(($date2-$date1))
echo "M-R took $diff sec. Output/Error in 'test.out'"
echo RESULT:
hdfs dfs -cat output/*
