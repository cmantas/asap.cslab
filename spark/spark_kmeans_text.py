import argparse

parser = argparse.ArgumentParser(description='runs kmeans on spark for .csv files')

parser.add_argument("-k","--K", help="the K parameter of K-means", type=int, required=True)
parser.add_argument("-mi","--max_iterations", help="the max iterations of the algorithm", type=int, required=True)
parser.add_argument("-i", "--input",  help="the input dir (RDD)", required=True)
args = parser.parse_args()



k = args.K
max_iter = args.max_iterations
fname = args.input
if not fname.startswith('/'):
    print "Please specify an absolute path for the input"
    exit()

fname = "hdfs://master:9000/"+fname
runs = 1 #???

from pyspark import SparkContext
from pyspark.mllib.clustering import KMeans
from numpy import array
from math import sqrt
from pyspark.mllib.linalg import SparseVector


sc = SparkContext( appName="kmeans")

def myVec(line):
	from pyspark.mllib.linalg import SparseVector
	return  eval("SparseVector"+line)



# Load and parse the data
data = sc.textFile(fname).map(myVec)


# Build the model (cluster the data)
clusters = KMeans.train(data, k, maxIterations=max_iter, runs=runs, initializationMode="random")

#free space??
data.unpersist()


# # Evaluate clustering by computing Within Set Sum of Squared Errors
# def error(point):
#     center = clusters.centers[clusters.predict(point)]
#     return sqrt(sum([x**2 for x in (point - center)]))

# WSSSE = parsedData.map(lambda point: error(point)).reduce(lambda x, y: x + y)
# print("Within Set Sum of Squared Error = " + str(WSSSE))

f = open("spark_kmeans_centroids.out", "w+")
for c in clusters.clusterCenters:
    nzl = []
    for i in range(len(c)):
        if not c[i]>=0.1:
            nzl.append((i, c[i]))
    f.write(str(nzl))
    f.write("\n\n")


f.close()
