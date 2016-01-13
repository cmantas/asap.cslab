#!/usr/bin/env python 
__author__ = 'cmantas'
from time import sleep, time
import sys
from signal import signal, SIGTERM, SIGALRM
from json import dumps, load
from os import getpid, kill, remove
from shutil import move
from os.path import isfile
from pprint import pprint
from lib.GMonitor import GMonitor

# default metrics file
metrics_file = '/tmp/asap_monitoring_metrics.json'

# default sampling interval
interval = 5

# absolute max monitoring time
max_monitoring_time = 3*60*60 # 3 hours

pid_file = '/tmp/asap_monitoring.pid'


# the monitor instance
monitor = None

def print_out(*sigargs):
    """
    This prints out the
    this will be called in case of Ctrl-C or kill signal
    :return:
    """
    end_time = time()
    time_delta = end_time - start_time

    global monitor

    output = {'metrics_timeline': monitor.metrics_timeline,
              'metric_summaries_timeline': monitor.metrics_summaries_timeline,
              'time':time_delta,
              "iops_rd_total": monitor.iops_rd_total,
              "iops_wt_total": monitor.iops_wt_total,
              "net_out_total": monitor.net_out_total,
              "net_in_total": monitor.net_in_total
              }
    # output['start_time']= start_time
    # output['end_time'] = end_time

    if metrics_file is not None:
        # remove the old metrics file immediately
        try:remove(metrics_file)
        except: pass

        # open a temp file and write the metrics there
        tmp_file= '/tmp/asap_metrics_temp'
        with open(tmp_file, "w+") as f:
            f.write(dumps(output, indent=1))

        # after write is finished move the tmp file to the output file
        move(tmp_file, metrics_file)

        # print 'written on ', metrics_file, '\n'
    else:
        # console output
        print dumps(output, indent=1)
        sys.stdout.flush()
    # we are done, exit
    exit()


def send_kill():
    # read the pid from the pid file
    try:
        with open(pid_file) as f:
            monitor_pid=int(f.read())
            # send the stop signal to the active monitoring process
            kill(monitor_pid, SIGTERM)
    except:
        #print "Could not read the pid file"
        pass


def wait_for_file(filepath, timeout=3):
    end_time= time() + timeout
    #wait
    while not isfile(filepath) and time()<end_time:
        sleep(0.1)
    # if after wait no file then trouble
    if not isfile(filepath):
        print "ERROR: waited for monitoring data file, but timed out"
        exit()


def collect_metrics():
    # send sigterm in case there is another live monitoring process
    send_kill()

    try:
        # wait for the metrics file to be created (3 secs)
        wait_for_file(metrics_file)

        # collect the saved metrics from metrics file
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
    parser.add_argument('--summary', help="only keep a summary of metrics", action='store_true')
    parser.set_defaults(console=False)
    args = parser.parse_args()
##############################################################

    # if we are just collecting metrics, then do that and exit
    if args.collect_metrics:
        m = collect_metrics()
        if args.console:
            pprint(m)
        exit()

    # signal the previous process in case there is one
    send_kill()

    # delete any old metrics files
    try: remove(metrics_file)
    except: pass

    # chose the output file (or console)
    if args.file is not None: metrics_file = args.file
    elif args.console: metrics_file = None

    # the ganglia endpoint
    endpoint = (args.endpoint_host, args.endpoint_port)

    # create the monitor
    monitor = GMonitor(endpoint, summarized=args.summary)

    # store the pid in the temp file
    with open(pid_file, 'w+') as f: f.write(str(getpid()))

    #install the signal handler
    signal(SIGTERM, print_out)

    # start kepping time
    start_time = time()

    # failsafe timeout (in case monitoring is never stopped
    max_timeout = start_time +max_monitoring_time

    # until signaled or failsafe timeout expired, keep updating the metrics
    try:
        while time()<max_timeout:
            monitor.update_metrics()
            sleep(interval)
    except KeyboardInterrupt:
        print_out()
