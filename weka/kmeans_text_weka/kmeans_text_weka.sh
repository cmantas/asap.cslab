source $(dirname $0)/common.sh
echo "----------$ASAP_HOME-------"
input=$1
iterations=$3
clusters=$2

echo $input $clusters $iterations

echo "STEP 3/3: K-Means"

java -Xmx15g -cp ${WEKA} weka.clusterers.SimpleKMeans \
	     -N ${clusters} \
	     -I ${iterations}  \
	     -A "weka.core.EuclideanDistance -R first-last" \
	     -t $input \
	     > clusters.txt
head -n 30 clusters.txt
echo DONE KMEANS
rm clusters.txt	
