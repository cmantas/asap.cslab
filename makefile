DIRS = hadoop/asap-tools weka/kmeans_weka


home:=$(shell pwd | sed -e 's/\//\\\//g')

default: build install_scripts 

build:
	# Building things
	@for d in $(DIRS); do (cd $$d; $(MAKE) ); done

install_scripts:
	#Copying script(s)
	@cp scripts/asap.sh ~/bin/asap
	@echo Setting ASAP_HOME to asap script in '$(home)'
	@sed -i "s/.*ASAP_HOME=.*/ASAP_HOME='${home}'/g" ~/bin/asap
