 gnome-terminal -x sh -c "tail -f /tmp/pyspark_stderr; sleep 10"
spark-submit --master local[8] spark_kmeans_synth.py -k 6 -f /home/cmantas/Data/synth_clusters/200000_points_6_clusters.csv -i 10 2>/tmp/pyspark_stderr
