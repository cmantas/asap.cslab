#!/usr/bin/python

__author__ = 'cmantas'

from numpy.random import multivariate_normal, normal
from random import randint
from math import sqrt
from sys import maxint, argv
from os.path import isfile
from os import makedirs
from json import loads

print argv

min_points = int(argv[1])
max_points = int(argv[2])
points_step = int(argv[3])
min_clusters = int(argv[4])
max_clusters = int(argv[5])
clusters_step = int(argv[6])
out_dir = int(argv[7])


#threshold for png construction
image_threshold = 50000

#2d gauss generator
def gauss_2d(mean, sd, points=1):
    cov = [[sd,0],[0,sd]]
    # x,y = multivariate_normal(mean,cov,points).T
    x = normal(mean[0], sd, points)
    y = normal(mean[1], sd, points)
    return x,y

#lineal distance
def lin_dist(x, y):
    a = pow(x[0]-y[0], 2) + pow(x[1]-y[1], 2)
    return sqrt(a)


def generate_points(num_points, clusters, out_dir):
    if num_points<clusters:
        print "Cluster count is larger than points count. This is just wrong"
        exit(-2)
    # generate image or not?
    gen_image = True
    if image_threshold < num_points: gen_image = False
    #handle cluster sizes
    boundary = maxint
    name = "%d_points_%d_clusters" % (num_points, clusters)
    num_points = num_points/clusters

    info = "point,\t sd\n"

    #output file
    name=out_dir+"/"+name
    fname = name + ".csv"
    if isfile(fname):
        print "file \"%s\" already exists. Skipping" % fname
        return
    try: makedirs(out_dir)
    except: pass
    out_file = open(fname, "w+")


    centroids=[]

    for i in range(clusters):
        x = randint(-boundary, boundary)
        y = randint(-boundary, boundary)
        centroids.append([x,y])

    min_distances = []
    if len(centroids) > 1:
        for i in range(len(centroids)):
            dist =[]
            for j in range(len(centroids)):
                if i==j: continue
                dist.append(lin_dist(centroids[i],centroids[j]))
            min_distances.append(min(dist))
    else:
        min_distances.append(maxint)

    for i in range(len(centroids)):
        sd = min_distances[i]/5
        x,y = gauss_2d(centroids[i], sd, num_points)
        #write to file
        for d in range(len(x)): out_file.write("%d, %d\n" %(x[d],y[d]))



    out_file.close()

    #write info
    with open(name + "_info.txt", "w") as text_file:
        text_file.write(info)


for points in range(min_points, max_points+1, points_step):
    for clusters in range(min_clusters, max_clusters+1, clusters_step):
        print "Points: %d, clusters: %d" % (points, clusters)
        generate_points(points, clusters, out_dir)
