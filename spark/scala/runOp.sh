#sbt package

spark-submit \
--driver-memory=2G \
--executor-memory=4G \
--class Word2Vec \
target/scala-2.10/sparkops_2.10-1.0.jar \
"../Datasets/20newsSmall/*/*" 5
