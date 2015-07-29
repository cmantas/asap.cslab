__author__ = 'cmantas'
from tools import *





k_list=  [5,10,15,20];


# print list_k
# multi_graph("mahout_kmeans_text", "documents/1000", "avg(time/1000)", cond_producer("k", [5,10,15,20]), groupBy="documents", title="Mahout K-Means Documents vs Time")


# Spark Kmeans
# multi_graph("spark_kmeans_text", "avg(documents/1000)", "time/1000", cond_producer("minDF=10 and k", k_list), groupBy="documents", title="Spark Documents vs Time")
#
#
# exit()


# multi_graph("mahout_kmeans_text", "input_size/1048576", "time", ["k=5", "k=15", "k=15", "k=20"], groupBy="documents")
# exit()

# Weka Kmeans
# figure()
# for k in k_list:
#     draw_single_kmeans("weka",  k, 10)


# minDF vs time






## K-means
k=10
figure()
draw_single_kmeans("weka", k, 10,title="K-Means WEKA, Documents vs Time")
draw_single_kmeans("weka", k, 60)
draw_single_kmeans("weka", k, 110,  where_extra=" weka_tfidf.documents<5500")
draw_single_kmeans("weka", k, 160)

show()
exit()