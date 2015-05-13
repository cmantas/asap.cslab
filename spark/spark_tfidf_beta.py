import os
import sys



from pyspark import SparkContext
from pyspark.mllib.feature import HashingTF
from pyspark.mllib.feature import IDF


sc = SparkContext()

# Load documents (one per line).
documents = sc.textFile("/home/cmantas/Data/docs_virt_dir/text/").map(lambda line: line.split(" "))

# TF
hashingTF = HashingTF()
tf = hashingTF.transform(documents)


# IDF
tf.cache()
idf = IDF(minDocFreq=2).fit(tf)
tfidf = idf.transform(tf)


from pyspark.mllib.clustering import KMeans
clusters = KMeans.train(tf, 2, maxIterations=3, runs=2, initializationMode="random")
