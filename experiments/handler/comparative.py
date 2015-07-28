__author__ = 'cmantas'
from tools import *


# Kmeans mahout vs spark

m_q = """select mahout_kmeans_text.documents/1000, mahout_kmeans_text.time/1000
from mahout_tfidf inner join mahout_kmeans_text
ON
	mahout_tfidf.documents=mahout_kmeans_text.documents AND
	mahout_tfidf.dimensions=mahout_kmeans_text.dimensions
where minDF=10 and k={};"""
figure()
docs, terms = query2lists(m_q.format(20))
myplot(docs,terms, label="Mahout, k=20", title="K-Means, Mahout vs Spark", xlabel="#docs/1000", ylabel="#terms")
docs, terms = query2lists("select documents/1000, time/1000 from spark_kmeans_text WHERE k=20 and minDF=10")
myplot(docs,terms, label="Spark, k=20")



# tfidf
figure()
plot_from_query("select documents/1000, avg(time/1000) from spark_tfidf where minDF=10 and documents<130000 group by documents", label="Spark TF/IDF",  xlabel="#docs/1000", ylabel="time (sec)")

docs, terms = query2lists("select documents/1000, time/1000 from mahout_tfidf WHERE minDF=10")
myplot(docs,terms, label="Mahout, minDF=10")



show()

