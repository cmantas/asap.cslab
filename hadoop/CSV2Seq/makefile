all:
	mvn clean compile assembly:single >/dev/null;
	mkdir -p ~/bin/lib &>/dev/null;  mv target/*-jar-with-dependencies.jar ~/bin/lib/CSV2Seq.jar
	
