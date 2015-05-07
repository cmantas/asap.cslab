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

# figure()
# docs, terms = query2lists("select documents, avg(dimensions) from mahout_tfidf WHERE minDF=10 GROUP by documents;")
# myplot(docs,terms, label="mahout, minDF=10", title="Documents vs Terms", xlabel="#docs", ylabel="#terms")
# docs, terms = query2lists("select documents, avg(dimensions) from weka_tfidf WHERE minDF=10 GROUP by documents;")
# myplot(docs,terms, label="weka, minDF=10")
# show()
#
# figure()
# docs, terms = query2lists("select documents, avg(time) from mahout_tfidf WHERE minDF=10 GROUP by documents;")
# myplot(docs,terms, label="mahout", title="Documents vs time", xlabel="#docs", ylabel="#terms")
# docs, terms = query2lists("select documents, avg(time) from weka_tfidf WHERE minDF=10 GROUP by documents;")
# myplot(docs,terms, label="weka")
# show()
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



############ weka vs mahout #############
figure()
k=11; minDF=10
query="select k.documents, k.time from \n" \
           " {2}_kmeans_text as k inner join {2}_tfidf as i \n" \
           " on k.dimensions=i.dimensions \n" \
           " where i.minDF={0} and k.k={1} and k.documents<=12000 group by k.documents;"
# query_weka = query.format(minDF,k,"weka")
# docs, times = query2lists(query_weka)
# times = [ float(t)/1000 for t in times]
# myplot(docs, times, 'o-', label="weka k=%d"%k, title="Weka vs Mahout (minDF={0}".format(minDF), xlabel="#docs", ylabel="time(sec)")
# query_mahout = query.format(minDF,k,"mahout")
# docs, times = query2lists(query_mahout)
# times = [ float(t)/1000 for t in times]
# myplot(docs, times, 's-', label="mahout k=%d"%k)

k=16
query_weka = query.format(minDF,k,"weka")
docs, times = query2lists(query_weka)
times = [ float(t)/1000 for t in times]
myplot(docs, times, 'o-', label="weka k=%d"%k,  title="Weka vs Mahout (minDF={0})".format(minDF), xlabel="#docs", ylabel="time(sec)")

query_mahout = query.format(minDF,k,"mahout")
docs, times = query2lists(query_mahout)
times = [ float(t)/1000 for t in times]
myplot(docs, times, 's-', label="mahout k=%d"%k)
show()


### mahout multi K ###
k=1;
figure()
query_mahout = query.format(minDF,k,"mahout")
docs, times = query2lists(query_mahout)
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="k=1", title="Mahout K-Means", xlabel="#docs", ylabel="time(sec)")
k=6; minDF=10
docs, times = query2lists(query.format(minDF,k,"mahout"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="mahout k=6")
k=11; minDF=10
docs, times = query2lists(query.format(minDF,k,"mahout"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="mahout k=11")
k=16; minDF=10
docs, times = query2lists(query.format(minDF,k,"mahout"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="mahout k=16")
show()

### weka multi K

k=1;
figure()
query_mahout = query.format(minDF,k,"weka")
docs, times = query2lists(query_mahout)
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="k=1", title="Weka K-Means", xlabel="#docs", ylabel="time(sec)")
k=6; minDF=10
docs, times = query2lists(query.format(minDF,k,"weka"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="weka k=6")
k=11; minDF=10
docs, times = query2lists(query.format(minDF,k,"weka"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="weka k=11")
k=16; minDF=10
docs, times = query2lists(query.format(minDF,k,"weka"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="weka k=16")
k=21; minDF=10
docs, times = query2lists(query.format(minDF,k,"weka"))
times = [ float(t)/1000 for t in times]
myplot(docs, times,'o-', label="weka k=%d"%k)
show()



