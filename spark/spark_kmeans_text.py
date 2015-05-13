import argparse

parser = argparse.ArgumentParser(description='runs kmeans on spark for .csv files')

parser.add_argument("-k","--K", help="the K parameter of K-means", type=int, required=True)
parser.add_argument("-i","--max_iterations", help="the max iterations of the algorithm", type=int, required=True)
parser.add_argument("-input", help="the input dir (RDD)", required=True)
parser.add_argument("--distributed_file", '-df', help="the input file in HDFS", )
parser.add_argument('-d', action='store_true', default=False)
args = parser.parse_args()



k = args.K
max_iter = args.max_iterations
fname = args.input
dfs = args.d

from pyspark import SparkContext
from pyspark.mllib.clustering import KMeans
from numpy import array
from math import sqrt
from pyspark.mllib.linalg import SparseVector

####### RUNS ???? #######
runs = 2 #how many parallel runs
threads = 4


sc = SparkContext("local[%d]" % threads, "kmeans")

def myVec(line):
	from pyspark.mllib.linalg import SparseVector
	return  eval("SparseVector"+line)



# Load and parse the data
data = sc.textFile(fname).map(myVec)
parsedData = data.map(lambda line: ast.litteral_eval() )

# Build the model (cluster the data)
clusters = KMeans.train(data, k, maxIterations=max_iter, runs=runs, initializationMode="random")


# # Evaluate clustering by computing Within Set Sum of Squared Errors
# def error(point):
#     center = clusters.centers[clusters.predict(point)]
#     return sqrt(sum([x**2 for x in (point - center)]))

# WSSSE = parsedData.map(lambda point: error(point)).reduce(lambda x, y: x + y)
# print("Within Set Sum of Squared Error = " + str(WSSSE))

for c in clusters.clusterCenters:
    print c
