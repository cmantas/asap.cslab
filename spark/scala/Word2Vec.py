__author__ = "gsvic"
"""
Spark Word2Vec operator

Run: spark-submit Word2Vec.py $INPUT_PATH
"""
import sys, time
from pyspark import SparkConf, SparkContext
from pyspark.mllib.feature import Word2Vec

try:
	input_folder = sys.argv[1]
except:
	print("Missing/Invalid input path")
	exit()

#Spark Context
sc = SparkContext( appName="Word2Vec_PySpark" )

#Input documents mapping: (docName, docText) -> [t1, t2, ..., tn]
corpus = (sc.wholeTextFiles(input_folder)
          .map(lambda (fileName, doc) : doc.split(" ")))

#Train Word2Vec model
word2vec = Word2Vec()
start = time.time()
model = word2vec.fit(corpus)
exec_time = time.time() - start

output = dict()
output['operator'] = "Word2Vec_PySpark"
output['execTime'] = int(exec_time)