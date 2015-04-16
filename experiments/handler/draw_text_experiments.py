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

conn = sqlite3.connect('../results.db')
c = conn.cursor()


def query2lists(query):
    rv = []
    query = query.lower()
    fi = query.find("from")
    si = query.find("select")
    attributes = len(query[si+6:fi].split(","))
    for i in range(attributes):
        rv.append([])

    rows = c.execute(query)
    # if k is None :
    for row in rows:
        for i in range(attributes):
            rv[i].append(row[i])

    return tuple(rv)


def myplot(*args, **kwargs):
    if "title" in kwargs:
        title = kwargs["title"]
        del(kwargs["title"])
        plt.title(title)
    if "xlabel" in kwargs:
        xlabel = kwargs["xlabel"]
        del(kwargs["xlabel"])
        plt.xlabel(xlabel)
    if "ylabel" in kwargs:
        ylabel = kwargs["ylabel"]
        del(kwargs["ylabel"])
        plt.ylabel(ylabel)
    plt.plot(*args, **kwargs)
    plt.legend(loc = 'upper left')

#


figure()
docs, terms = query2lists("select documents, terms from mahout_tfidf group by documents;")
myplot(docs,terms, label="mahout", title="Documents vs Terms", xlabel="#docs", ylabel="#terms")
docs, terms = query2lists("select documents, dimensions from weka_tfidf group by documents;")
myplot(docs,terms, label="weka")
show()


############# mahout kmeans text ######\
# figure()
# docs, times = query2lists("select documents, avg(time) from mahout_kmeans_text where k=11 GROUP by documents")
# times = [ float(t)/1000 for t in times]
# myplot(docs,times, label="k=11", title="Mahout K-means text", xlabel="#docs", ylabel="avg time(sec)")
# docs, times = query2lists("select documents, avg(time) from mahout_kmeans_text where k=21 GROUP by documents")
# times = [ float(t)/1000 for t in times]
# myplot(docs,times, label="k=21",)
# show()
#
# figure()
# docs, times = query2lists("select documents, time from mahout_kmeans_text where k=11 and max_df=95 ")
# times = [ float(t)/1000 for t in times]
# myplot(docs,times, label="k=11", title="Mahout K-means for maxdf=95", xlabel="#docs", ylabel="time(sec)")
# docs, times = query2lists("select documents, time from mahout_kmeans_text where k=21 and max_df=95")
# times = [ float(t)/1000 for t in times]
# myplot(docs,times, label="k=21",)
# show()

#
# figure()
# docs, times = query2lists("select documents, time from weka_kmeans_text where k=6 GROUP by documents")
# times = [ float(t)/1000 for t in times]
# myplot(docs,times, label="k=6", title="weka K-means", xlabel="#docs", ylabel="time(sec)")
# docs, times = query2lists("select documents, time from weka_kmeans_text where k=21 GROUP by documents")
# docs, times = query2lists("select documents, time from weka_kmeans_text where k=11 GROUP by documents")
# times = [ float(t)/1000 for t in times]
# myplot(docs,times, label="k=11", title="weka K-means", xlabel="#docs", ylabel="time(sec)")
# docs, times = query2lists("select documents, time from weka_kmeans_text where k=21 GROUP by documents")
# times = [ float(t)/1000 for t in times]
# myplot(docs,times, label="k=21",)
# show()