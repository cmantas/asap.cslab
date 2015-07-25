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

#mahout #terms for varying minDF
# figure()
# docs, terms = query2lists("select documents, avg(dimensions) from mahout_tfidf WHERE minDF=10 GROUP by documents;")
# myplot(docs,terms, label="minDF=10", title="Documents vs Terms", xlabel="#docs", ylabel="#terms")
# docs, terms = query2lists("select documents, avg(dimensions) from mahout_tfidf WHERE minDF=60 GROUP by documents;")
# myplot(docs,terms, label="minDF=60", title="Documents vs Terms", xlabel="#docs", ylabel="#terms")
# docs, terms = query2lists("select documents, avg(dimensions) from mahout_tfidf WHERE minDF=110 GROUP by documents;")
# myplot(docs,terms, label="minDF=110", title="Documents vs Terms", xlabel="#docs", ylabel="#terms")
# docs, terms = query2lists("select documents, avg(dimensions) from mahout_tfidf WHERE minDF=160 GROUP by documents;")
# myplot(docs,terms, label="minDF=160", title="Mahout Documents vs Terms", xlabel="#docs", ylabel="#terms")
# show()
# exit()


# mahout tfidf docs vs time
# figure()
# docs, terms = query2lists("select documents, avg(time) from mahout_tfidf WHERE minDF=10 GROUP by documents;")
# myplot(docs,terms, label="minDF=10", title="Documents vs time", xlabel="#docs", ylabel="#terms")
# docs, terms = query2lists("select documents, avg(time) from mahout_tfidf WHERE minDF=60 GROUP by documents;")
# myplot(docs,terms, label="minDF=60", title="Documents vs time", xlabel="#docs", ylabel="#terms")
# docs, terms = query2lists("select documents, avg(time) from mahout_tfidf WHERE minDF=110 GROUP by documents;")
# myplot(docs,terms, label="minDF=110", title="Documents vs time", xlabel="#docs", ylabel="#terms")
# docs, terms = query2lists("select documents, avg(time) from mahout_tfidf WHERE minDF=160 GROUP by documents;")
# myplot(docs,terms, label="minDF=160", title="Documents vs time", xlabel="#docs", ylabel="#terms")
# show()
# exit()

def multi_graph(table, x, y, cond_list, title=None, xlabel=None, ylabel=None, groupBy=""):
    if title is None:
        title = x+" vs "+y
    if xlabel is None:
        xlabel=x
    if ylabel is None:
        ylabel = y
    if groupBy !="":
        groupBy = "group by "+groupBy

    figure()
    for c in cond_list:
        query = "select {0} from {1} where {2} {3}".format(x+','+y, table, c, groupBy)
        rx, ry = query2lists(query)
        myplot(rx,ry, label=c, title=title, xlabel=xlabel, ylabel=ylabel)
    show()

# multi_graph("mahout_tfidf", "input_size/1048576", "output_size/1048576", ["minDF=10", "minDF=60","minDF=110","minDF=160"], xlabel='input MB', ylabel='output MB', title="Mahout Input vs Output size")
# exit()

multi_graph("mahout_kmeans_text", "documents/1000", "time/1000", ["k=5", "k=10", "k=15", "k=20"], groupBy="documents", title="Documents vs Time")
exit()

# multi_graph("mahout_kmeans_text", "input_size/1048576", "time", ["k=5", "k=10", "k=15", "k=20"], groupBy="documents")
# exit()


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


#
# ############ weka vs mahout #############
# figure()
k=11; minDF=10
query="select k.documents, k.time from \n" \
           " {2}_kmeans_text as k inner join {2}_tfidf as i \n" \
           " on k.dimensions=i.dimensions \n" \
           " where i.minDF={0} and k.k={1} group by k.documents;"

# # query_weka = query.format(minDF,k,"weka")
# # docs, times = query2lists(query_weka)
# # times = [ float(t)/1000 for t in times]
# # myplot(docs, times, 'o-', label="weka k=%d"%k, title="Weka vs Mahout (minDF={0}".format(minDF), xlabel="#docs", ylabel="time(sec)")
# # query_mahout = query.format(minDF,k,"mahout")
# # docs, times = query2lists(query_mahout)
# # times = [ float(t)/1000 for t in times]
# # myplot(docs, times, 's-', label="mahout k=%d"%k)
#
# k=16
# query_weka = query.format(minDF,k,"weka")
# docs, times = query2lists(query_weka)
# times = [ float(t)/1000 for t in times]
# myplot(docs, times, 'o-', label="weka k=%d"%k,  title="Weka vs Mahout (minDF={0})".format(minDF), xlabel="#docs", ylabel="time(sec)")
#
# query_mahout = query.format(minDF,k,"mahout")
# docs, times = query2lists(query_mahout)
# times = [ float(t)/1000 for t in times]
# myplot(docs, times, 's-', label="mahout k=%d"%k)
# show()
#
#
# ### mahout multi K ###
# k=1;
# figure()
# query_mahout = query.format(minDF,k,"mahout")
# docs, times = query2lists(query_mahout)
# times = [ float(t)/1000 for t in times]
# myplot(docs, times,'o-', label="k=1", title="Mahout K-Means", xlabel="#docs", ylabel="time(sec)")
# k=6; minDF=10
# docs, times = query2lists(query.format(minDF,k,"mahout"))
# times = [ float(t)/1000 for t in times]
# myplot(docs, times,'o-', label="mahout k=6")
# k=11; minDF=10
# docs, times = query2lists(query.format(minDF,k,"mahout"))
# times = [ float(t)/1000 for t in times]
# myplot(docs, times,'o-', label="mahout k=11")
# k=16; minDF=10
# docs, times = query2lists(query.format(minDF,k,"mahout"))
# times = [ float(t)/1000 for t in times]
# myplot(docs, times,'o-', label="mahout k=16")
# show()
#
# ### weka multi K
#
# k=1;
# figure()
# query_mahout = query.format(minDF,k,"weka")
# docs, times = query2lists(query_mahout)
# times = [ float(t)/1000 for t in times]
# myplot(docs, times,'o-', label="k=1", title="Weka K-Means", xlabel="#docs", ylabel="time(sec)")
# k=6; minDF=10
# docs, times = query2lists(query.format(minDF,k,"weka"))
# times = [ float(t)/1000 for t in times]
# myplot(docs, times,'o-', label="weka k=6")
# k=11; minDF=10
# docs, times = query2lists(query.format(minDF,k,"weka"))
# times = [ float(t)/1000 for t in times]
# myplot(docs, times,'o-', label="weka k=11")
# k=16; minDF=10
# docs, times = query2lists(query.format(minDF,k,"weka"))
# times = [ float(t)/1000 for t in times]
# myplot(docs, times,'o-', label="weka k=16")
# k=21; minDF=10
# docs, times = query2lists(query.format(minDF,k,"weka"))
# times = [ float(t)/1000 for t in times]
# myplot(docs, times,'o-', label="weka k=%d"%k)
# show()


# ############ spark vs mahout #############
figure()
k=15; minDF=10
query="select k.documents, k.time from \n" \
           " {2}_kmeans_text as k inner join {2}_tfidf as i \n" \
           " on k.dimensions=i.dimensions \n" \
           " where i.minDF={0} and k.k={1} group by k.documents;"

query_spark = query.format(minDF,k,"spark")
docs, times = query2lists(query_spark)
times = [ float(t)/1000 for t in times]
myplot(docs, times, 'o-', label="spark k=%d"%k, title="Spark vs Mahout (minDF={0}".format(minDF), xlabel="#docs", ylabel="time(sec)")
query_mahout = query.format(minDF,k,"mahout")
docs, times = query2lists(query_mahout)
times = [ float(t)/1000 for t in times]
myplot(docs, times, 's-', label="mahout k=%d"%k)
show()

################ spark ##########################
k=5;minDF=10
figure()
query_spark = query.format(minDF,k,"spark")
docs, times = query2lists(query_spark)
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="k=5", title="spark K-Means", xlabel="#docs", ylabel="time(sec)")
k=10;
docs, times = query2lists(query.format(minDF,k,"spark"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="spark k=10")
k=15;
docs, times = query2lists(query.format(minDF,k,"spark"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="spark k=15")
k=20;
docs, times = query2lists(query.format(minDF,k,"spark"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="spark k=20")
show()


################ mahout ##########################
k=5;minDF=10
figure()
query_mahout = query.format(minDF,k,"mahout")
docs, times = query2lists(query_mahout)
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="k=5", title="mahout K-Means", xlabel="#docs", ylabel="time(sec)")
k=10;
docs, times = query2lists(query.format(minDF,k,"mahout"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="mahout k=10")
k=15;
docs, times = query2lists(query.format(minDF,k,"mahout"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="mahout k=15")
k=20;
docs, times = query2lists(query.format(minDF,k,"mahout"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="mahout k=20")
show()