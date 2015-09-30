#!/usr/bin/env python 
__author__ = 'cmantas'
from xml.parsers.expat import ParserCreate
import socket
from time import sleep, time
import sys
from signal import signal, SIGTERM, SIGALRM
import xmltodict
from json import dumps, load
from os import getpid, kill, remove

# default metrics file
metrics_file = '/tmp/asap_monitoring_metrics.json'

# default sampling interval
interval = 5

pid_file = '/tmp/asap_monitoring.pid'


def get_metrics(endpoint):

    attempts = 0

    while attempts <= 3:
        attempts += 1
        try:
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
        except:
            sleep(0.5)
    return None


def get_summary(endpoint):
    """
    From the available ganglia metrics returns only the useful ones
    """
    allmetrics = get_metrics(endpoint)
    if allmetrics is None:
        return None
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


def print_out(*sigargs):
    """
    This prints out the
    this will be called in case of Ctrl-C or kill signal
    :return:
    """
    global start_time
    end_time = time()
    time_delta = end_time - start_time

    output = {'metrics_timeline': metrics_timeline, 'time':time_delta }
    # output['start_time']= start_time
    # output['end_time'] = end_time

    if metrics_file is not None:
        with open(metrics_file, "w+") as f:
            f.write(dumps(output, indent=1))
        # print 'written on ', metrics_file, '\n'
    else:
        # console output
        print dumps(output, indent=1)
        sys.stdout.flush()
    # we are done, exit
    exit()


def collect_metrics():
    # read the pid from the pid file

    with open(pid_file) as f: monitor_pid=int(f.read())

    try:
        # send the stop signal to the active monitoring process
        kill(monitor_pid, SIGTERM)
        # sleep to allow flushing data
        sleep(0.5)
        # collect the saved metrics
        with open(metrics_file) as f:
            metrics = load(f)
        return metrics
    except:
        print 'Could not collect the metrics'
    finally:
        # remove the pid file
        try: remove(pid_file)
        except: pass


# print get_summary(("master", 8649))

if __name__ == "__main__":

############### args parsing #################
    from argparse import  ArgumentParser
    parser = ArgumentParser(description='Monitoring')
    parser.add_argument("-f", '--file', help="the output file to use")
    parser.add_argument("-c", '--console', help="output the metrics in console", dest='console', action='store_true')
    parser.add_argument("-eh", '--endpoint-host', help="the ganglia endpoing hostname or IP", default="master")
    parser.add_argument("-ep", '--endpoint-port', help="the ganglia endpoing port", type=int, default=8649)
    parser.add_argument("-cm", '--collect-metrics', help="collect the metrics", action='store_true')
    parser.set_defaults(console=False)
    args = parser.parse_args()
##############################################################

    # if we are just collecting metrics, then do that and exit
    if args.collect_metrics:
        m = collect_metrics()
        print m
        exit()

    # delete any old metrics files
    try: remove(metrics_file)
    except: pass

    # chose the output file (or console)
    if args.file is not None:
        metrics_file = args.file
    elif args.console:
        metrics_file = None
    # print 'Using output file: ', metrics_file

    # the ganglia endpoint
    endpoint = (args.endpoint_host, args.endpoint_port)

    # the timeline of metric values
    metrics_timeline = []

    # store the pid in the temp file
    with open(pid_file, 'w+') as f: f.write(str(getpid()))

    #install the signal handler
    signal(SIGTERM, print_out)

    # start kepping time
    start_time = time()

    try:
        iterations = 0
        while True:
            metric_values = get_summary(endpoint)
            if metric_values is None: continue
            metrics_timeline.append((iterations*interval, metric_values))
            iterations += 1
            sleep(interval)
    except KeyboardInterrupt:
        print_out()
