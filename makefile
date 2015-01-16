DIRS =weka/kmeans_weka/ hadoop/CSV2Seq/

all:
	-for d in $(DIRS); do (cd $$d; $(MAKE) ); done

	
