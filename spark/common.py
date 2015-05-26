#!/usr/bin/env pyspark
__author__ = 'cmantas'


from os import environ

core_site = environ['HADOOP_HOME']+"/etc/hadoop/core-site.xml"

with open(core_site) as f:
    content = f.readlines()

hdfs_master = "localhost"

for line in content:
    if "hdfs" not in line.lower():
        continue
    host_start = line.index("://")+3
    line = line[host_start:]
    host_end = line.index(":")
    hdfs_master= line[:host_end]

