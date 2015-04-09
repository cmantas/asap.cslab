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
# ####### points vs time ##################
# k=6
# dim=1002
# query = "select points, avg(time)from weka_kmeans_synth where k={0} and dimensions={1} group by points,dimensions;".format(k,dim)
# points=[]; times=[]
# rows = c.execute(query)
# # if k is None :
# for row in rows:
#     points.append(row[0])
#     times.append(row[1])
#
#
# fig = plt.figure()
# plt.plot(points, times, label="K=6, dim 1002")
#
# k=6
# dim=5002
# query = "select points, avg(time)from weka_kmeans_synth where k={0} and dimensions={1} group by points,dimensions;".format(k,dim)
# points=[]; times=[]
# rows = c.execute(query)
# # if k is None :
# for row in rows:
#     points.append(row[0])
#     times.append(row[1])
#
#
# plt.plot(points, times, label="K=6, dim 5002")
#
# plt.xlabel('# points')
# plt.ylabel('time')
# plt.legend(loc = 'upper left')
# plt.show()
#
# ############### dimensions vs time  ################
#
# k=6
# points=10100
# query = "select dimensions, avg(time)from weka_kmeans_synth where k={0} and points={1} group by points,dimensions;".format(k,points)
# dimensions=[]; times=[]
# rows = c.execute(query)
# # if k is None :
# for row in rows:
#     dimensions.append(row[0])
#     times.append(row[1])
#
#
# fig = plt.figure()
# ax = fig.add_subplot(111)
# #ax = fig.gca(projection='3d')
# ax.plot(dimensions, times, label="points=10100")
#
#
# ax.set_xlabel('# dimensions')
# ax.set_ylabel('# time')
#
#
# # points, dimensions, times = get_3d_experiment(6)
# #
# # ax.plot(points, dimensions, times, "x", label="K=6")
# ax.legend(loc = 'upper left')
#
# plt.show()


############## mahout kmeans text ######\
figure()
docs, times = query2lists("select documents, avg(time) from mahout_kmeans_text where k=11 GROUP by documents")
times = [ float(t)/1000 for t in times]
myplot(docs,times, label="mahout k=11", title="Mahout K-means", xlabel="#docs", ylabel="time(sec)")
docs, times = query2lists("select documents, avg(time) from weka_kmeans_text where k=11 GROUP by documents")
times = [ float(t)/1000 for t in times]
myplot(docs,times, label="weka k=11",)
show()

