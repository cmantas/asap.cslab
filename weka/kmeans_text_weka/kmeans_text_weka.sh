source $(dirname $0)/common.sh
iterations=$2
clusters=$1

echo "STEP 3/3: K-Means"

java -Xmx15g -cp ${WEKA} weka.clusterers.SimpleKMeans \
	     -N ${clusters} \
	     -I ${iterations}  \
	     -A "weka.core.EuclideanDistance -R first-last" \
	     -t ${WD}/tf_idf_data.arff \
	     > clusters.txt
head -n 30 clusters.txt
echo DONE KMEANS
rm clusters.txt	
