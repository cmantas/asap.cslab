#!/usr/bin/env python
__author__ = 'cmantas'
import sqlite3
import matplotlib.pyplot as plt
import argparse
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import matplotlib.pyplot as plt
import numpy as np

conn = sqlite3.connect('../results.db')
c = conn.cursor()



query = "select points, dimensions, avg(time)from weka_kmeans_synth where k={0} group by points,dimensions;".format(k)
print query
points=[]; times=[]; dimensions=[]
rows = c.execute(query)
    # if k is None :
for row in rows:
    points.append(row[0])
    times.append(row[2])
    dimensions.append(row[1])
    return points, dimensions, times


points, dimensions, times = get_3d_experiment(1)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
#ax = fig.gca(projection='3d')
ax.plot(points, dimensions, times,'.', label="K=1")



ax.set_xlabel('# data points')
ax.set_ylabel('# dimensions')
ax.set_zlabel('time (sec)')



# points, dimensions, times = get_3d_experiment(6)
#
# ax.plot(points, dimensions, times, "x", label="K=6")
ax.legend(loc = 'upper left')

plt.show()