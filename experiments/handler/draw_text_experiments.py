#!/usr/bin/env python
__author__ = 'cmantas'
import sqlite3
import matplotlib.pyplot as plt
import argparse
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import matplotlib.pyplot as plt
from matplotlib.pyplot import figure, show
import numpy as np
from tools import *





# multi_graph("mahout_tfidf", "documents/1000", "dimensions/1000", ["minDF=10", "minDF=60","minDF=110","minDF=160"], title="Mahout Documents vs Terms")
# exit()

# multi_graph("mahout_tfidf", "documents/1000", "time/1000", ["minDF=10", "minDF=60","minDF=110","minDF=160"], ylabel='time (sec)', title="Mahout Documents vs Time")
# exit()

# multi_graph("mahout_tfidf", "input_size/1048576", "output_size/1048576", ["minDF=10", "minDF=60","minDF=110","minDF=160"], xlabel='input MB', ylabel='output MB', title="Mahout Input vs Output size")
# exit()

# Mahout Kmeans
list_k = cond_producer("minDF=10 and k", [5,10,15,20])
# print list_k
# multi_graph("mahout_kmeans_text", "documents/1000", "avg(time/1000)", cond_producer("k", [5,10,15,20]), groupBy="documents", title="Mahout K-Means Documents vs Time")
#
#
# # Spark Kmeans
# multi_graph("spark_kmeans_text", "avg(documents/1000)", "time/1000", list_k, groupBy="documents", title="Spark Documents vs Time")
# show()
#
#
# exit()


# multi_graph("mahout_kmeans_text", "input_size/1048576", "time", ["k=5", "k=15", "k=15", "k=20"], groupBy="documents")
# exit()





# spark tfidf minDF vs output size
# multi_graph("spark_tfidf", "documents/1000", "time/1000", ["minDF=10 and documents<120000", "minDF=60", "minDF=110", "minDF=160"],  title="Documents vs Time", ylabel="time (sec)", groupBy="documents")

plot_from_query("select documents/1000,time/1000 from spark_tfidf where minDF=10 and documents<120000 group by documents", label="minDF=10", title="Spark TF/IDF", ylabel="time (sec)", xlabel="#docs/1000")
plot_from_query("select documents/1000,time/1000 from spark_tfidf where minDF=60 group by documents", label="minDF=60")
plot_from_query("select documents/1000,time/1000 from spark_tfidf where minDF=110 group by documents", label="minDF=110")
plot_from_query("select documents/1000,time/1000 from spark_tfidf where minDF=160 group by documents", label="minDF=160")
show()

exit()


# #spark kmeans impact of minDF on time
# multi_graph("spark_kmeans_text", "documents/1000", "time/1000", ["minDF=10 and k=15", "minDF=60 and k=15", "minDF=110 and k=15", "minDF=160 and k=15"],  title="Documents vs Time", ylabel="output_size (MB)")
# show()
# exit()

# spark kmeans multi K
multi_graph("spark_kmeans_text", "documents/1000", "time/1000", ["minDF=10 and k=15", "minDF=60 and k=15", "minDF=110 and k=15", "minDF=160 and k=15"],  title="Documents vs Time", ylabel="output_size (MB)")
# show()

# #spark tfidf impact of minDF on output size
# multi_graph("spark_tfidf", "documents/1000", "output_size/1048576", ["minDF=10 ", "minDF=60 ", "minDF=110", "minDF=160"],  title="Documents vs Time", ylabel="output size (MB)")
# show()
# exit()

#mahout tfidf impact of minDF on output size
multi_graph("mahout_tfidf", "documents/1000", "output_size/1048576", list_k,  title="Mahout TF/IDF Documents vs Time", ylabel="output size (MB)")
show()
exit()

#mahout vs spark tfidf
figure()
rx, ry = query2lists("select documents/1000 ,avg(time/1000) from mahout_tfidf group by documents ")
rx, ry = query2lists("select documents/1000 ,avg(time/1000) from spark_tfidf group by documents ")
myplot(rx,ry)
show()
exit()

# dimensions vs time
figure()
rx, ry = query2lists("select dimensions/1000 ,time/1000 from mahout_kmeans_text where k=20 and documents=60300 ")
myplot(rx,ry, title="Dimensions vs time", xlabel="dimensions (x1000)", ylabel="time (sec)")
rx, ry = query2lists("select dimensions/1000,time/1000 from mahout_kmeans_text where k=20 and documents=70300")
myplot(rx,ry)
rx, ry = query2lists("select dimensions/1000,time/1000 from mahout_kmeans_text where k=20 and documents=80300")
myplot(rx,ry)
show()
exit()
#
#
# figure()
# minDF=10
# query = "select documents, avg(dimensions) from weka_tfidf where mindf=%d and documents<=11000 group by documents;"
# docs,terms = query2lists(query%minDF)
# myplot(docs,terms, label="minDF=%d"%minDF, title="Weka Documents vs Terms", xlabel="#docs", ylabel="#terms")
# minDF=110
# docs,terms = query2lists(query%minDF)
# myplot(docs,terms, label="minDF=%d"%minDF)
# minDF=210
# docs,terms = query2lists(query%minDF)
# myplot(docs,terms, label="minDF=%d"%minDF)
# minDF=310
# docs,terms = query2lists(query%minDF)
# myplot(docs,terms, label="minDF=%d"%minDF)
# show()




