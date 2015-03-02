#!/usr/bin/env python
__author__ = 'cmantas'
import sqlite3
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser(description='this is a description.')
parser.add_argument("name", nargs='+', help="the name of the experiment to plot")
parser.add_argument("-k", "-K", type=int, help="the K value of K-Means")
args = parser.parse_args()

exp_name = args.name
k = args.k


conn = sqlite3.connect('../results.db')
c = conn.cursor()

def get_data_size_name(exp_name):
    if "text" in exp_name:
        return "documents"
    elif "synth" in exp_name:
        return "points"
    else:
        raise Exception("Do not know the data point for"+exp_name)

def get_experiment(exp_name, k=None):
    data_name = get_data_size_name(exp_name)

    if k is None:
        query = "SELECT {0}, AVG(time) FROM {1} GROUP BY {0}".format(data_name, exp_name)
    else :
        query = "SELECT {0}, time FROM {1} WHERE k={2} ORDER BY {0}".format(data_name, exp_name,k)
    print query
    points=[]; times=[]
    for row in c.execute(query):
        points.append(row[0])
        times.append(row[1])
    return points, times



for exp_name in args.name:
    points, times = get_experiment(exp_name, k)
    plt.plot(points, times,  label=exp_name)

plt.legend(loc=2);
plt.show()