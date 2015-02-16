DIRS =weka/kmeans_weka/ hadoop/CSV2Seq/

all:
	-for d in $(DIRS); do (cd $$d; $(MAKE) ); done

sync:
	git commit -am "sync"; git push; ssh imr_master "cd asap.cslab; git pull"

	
