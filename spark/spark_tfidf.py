from math import sqrt
import argparse
from getpass import getuser

### args parsing
parser = argparse.ArgumentParser(description='runs TF/IDF on a directory of text docs')
parser.add_argument("-i","--input", help="the input directory",  required=True)

parser.add_argument("-lo", '--local_output', help="the output file (local)", )
parser.add_argument("-do", "--distributed_output",  help="the output file in HDFS", )

args = parser.parse_args()

d_out = args.distributed_output
l_out = args.local_output
docs_dir = args.input

if d_out is None and l_out is None:
    print "Please specify a local or distributed output"
    exit(-1)


# import spark things
from pyspark import SparkContext
from pyspark.mllib.feature import HashingTF
from pyspark.mllib.feature import IDF
sc = SparkContext()

min_df = 1


# Load documents (one per line).
documents = sc.textFile(docs_dir).map(lambda line: line.split(" "))

hashingTF = HashingTF()
tf = hashingTF.transform(documents)


# IDF
tf.cache()
idf = IDF(minDocFreq=2).fit(tf)
tfidf = idf.transform(tf)

#save
tfidf.saveAsTextFile(l_out)