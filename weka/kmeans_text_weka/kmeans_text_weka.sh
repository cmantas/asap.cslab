source $(dirname $0)/common.sh
iterations=$2
clusters=$1

echo "STEP 3/3: K-Means"

java -cp ${WEKA} weka.clusterers.SimpleKMeans \
	     -N ${clusters} \
	     -I ${iterations}  \
	     -A "weka.core.EuclideanDistance -R first-last" \
	     -t ${WD}/tf_idf_data.arff \
	     > clusters.txt
head -n 30 clusters.txt
rm clusters.txt	


rm -r $WD
