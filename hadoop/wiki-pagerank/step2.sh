hdfs dfs -rm -r /tmp/wiki_pagerank
hadoop jar target/*.jar PreProcessTask input/wikipedia /tmp/wiki_pagerank/initial 2>&1 2>&1 | grep ERROR:
hdfs dfs -cat  /tmp/wiki_pagerank/initial/part-r-00000 | head -n 2
