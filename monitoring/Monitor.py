#!/usr/bin/env python 
__author__ = 'cmantas'
from xml.parsers.expat import ParserCreate
import socket
from time import sleep
import sys
from signal import signal, SIGTERM
import xmltodict
from json import dumps



def get_metrics(endpoint):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(endpoint)

    xml = ""

    while 1:
        data = s.recv(1024)
        if len(data)==0: break
        xml+= data
    s.close()

    parsed = xmltodict.parse(xml)
    hosts =  parsed["GANGLIA_XML"]["CLUSTER"]["HOST"]

    allmetrics = {}
    for h in hosts:
        host = h["@NAME"]

        t =  map(lambda x: (x["@NAME"],x["@VAL"]) , h["METRIC"] )
        metrics = dict( (k,v) for k,v in t )
        allmetrics[host] = metrics

    return allmetrics

def get_summary(endpoint):

    allmetrics = get_metrics(endpoint)
    cpu =0
    mem = 0
    net_in = 0
    net_out = 0
    iops_read = 0
    iops_write = 0
    # pprint(allmetrics["master"].keys())
    for k, v in allmetrics.items():
        cpu += 100-float(v["cpu_idle"])
        total_mem = float(v["mem_free"]) + float(v["mem_buffers"]) +  float(v["mem_cached"])
        mem += 1.0 - float(v["mem_free"])/total_mem
        net_in += float(v["bytes_in"])
        net_out += float(v["bytes_out"])
        iops_read +=float( v.get("io_read", "-1"))
        iops_write +=float( v.get("io_write", "-1"))

    host_count = len(allmetrics.keys())
    return {
        "cpu": cpu / host_count,
        "mem": 100 * mem / host_count,
        "net_in": net_in,
        "net_out": net_out,
        "kbps_read": iops_read / host_count,
        "kbps_write": iops_write / host_count
    }






# print get_summary(("master", 8649))

if __name__ == "__main__":

    from argparse import  ArgumentParser
    parser = ArgumentParser(description='runs TF/IDF on a directory of text docs')
    parser.add_argument("-f", '--file', help="the output file to use")
    parser.add_argument("-eh", '--endpoint-host', help="the ganglia endpoing hostname or IP", default="master")
    parser.add_argument("-ep", '--endpoint-port', help="the ganglia endpoing port", type=int, default=8649)
    args = parser.parse_args()
##############################################################

    args.file
    endpoint = (args.endpoint_host, args.endpoint_port)

    metrics_timeline = []
    interval = 5

    def print_out(*sigargs):
        """
        this will be called in case of Ctrl-C or kill signal
        :return:
        """
        if args.file is None:
            print dumps(metrics_timeline, indent=1)
            sys.stdout.flush()
            sys.exit()
        else:
            with open(args.file, "w") as f:
                f.write(dumps(metrics_timeline, indent=1))
                exit()

    #install the signal handler
    signal(SIGTERM, print_out)

    try:
        iterations = 0
        while True:
            metric_values = get_summary(endpoint)
            metrics_timeline.append((iterations*interval, metric_values))
            iterations += 1
            sleep(interval)
    except KeyboardInterrupt:
        print_out()
