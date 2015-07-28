#!/usr/bin/env python
__author__ = 'cmantas'

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
# print plt.style.available
plt.style.use('fivethirtyeight')

def query2lists(query):
    print query
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

def take_single(query):
    rows = c.execute(query)
    for r in rows:
        return r


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
    plt.grid(True)
    # plt.grid(which='both')
    # plt.grid(which='minor', alpha=0.2)
    plt.plot(*args, **kwargs)
    plt.legend(loc = 'upper left')

def plot_from_query(query, **kwargs):
    x, y = query2lists(query)
    myplot(x, y, **kwargs)

def multi_graph(table, x, y, cond_list, groupBy="", **kwargs):
    if kwargs['title'] is None:
        kwargs['title'] = x+" vs "+y
    if 'xlabel' not in kwargs:
        kwargs['xlabel'] = x
    if 'ylabel' not in kwargs:
        kwargs['ylabel'] = y
    if groupBy != "":
        groupBy = "group by "+groupBy

    # for c in cond_list:
    #     query = "select {0} from {1} where {2} {3}".format(x+','+y, table, c, groupBy)
    #     rx, ry = query2lists(query)
    #     myplot(rx,ry, label=c, title=title, xlabel=xlabel, ylabel=ylabel)
    # show()
    query = "select {0} from {1} where ".format(x+","+ y, table) + "{0} " + groupBy
    multi_graph_query(query, cond_list, **kwargs)

def multi_graph_query(query, cond_list, **kwargs):
    figure()
    for c in cond_list:
        queryf = query.format(c)
        rx, ry = query2lists(queryf)
        myplot(rx,ry, label=c, **kwargs)


def cond_producer(a, list):
    return [a+"={}".format(i) for i in list]