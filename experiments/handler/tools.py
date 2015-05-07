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
    plt.grid(True)
    # plt.grid(which='both')
    # plt.grid(which='minor', alpha=0.2)
    plt.plot(*args, **kwargs)
    plt.legend(loc = 'upper left')