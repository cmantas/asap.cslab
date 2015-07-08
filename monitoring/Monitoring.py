#!/usr/bin/env python

import socket
# from lib.persistance_module import env_vars
import xml.parsers.expat
#import CassandraCluster as cluster_manager
from os.path import isfile
from time import sleep
# from lib.tiramola_logging import get_logger
import signal, sys

from json import dumps



import pprint
pp = pprint.PrettyPrinter(depth=6)
pprint = pp.pprint


LOG_FILENAME = 'files/logs/Coordinator.log'


class GParser:

    def __init__(self):
        self.inhost =0
        self.inmetric = 0
        self.allmetrics = {}
        self.currhostname = ""

    def parse(self, ganglia_file):
        """
        parses an xml ganglia file
        :param ganglia_file:
        :return: a dictionary of all ganlia metrics and their values
        """
        p = xml.parsers.expat.ParserCreate()
        p.StartElementHandler = self.start_element
        p.EndElementHandler = self.end_element
        p.ParseFile(ganglia_file)

        if self.allmetrics == {}: raise Exception('Host/value not found')
        return self.allmetrics

    def start_element(self, name, attrs):

        # edo xtizo to diplo dictionary. vazo nodes kai gia kathe node vazo polla metrics.
        #print attrs
        if name == "HOST":
            #if attrs["NAME"]==self.host:
            self.allmetrics[attrs["NAME"]]={}
            # edo ftiaxno ena adeio tuple me key to onoma tou node kai value ena adeio dictionary object.
            self.inhost=1
            self.currhostname = attrs["NAME"]
            #print "molis mpika sto node me dns " , self.currhostname

        elif self.inhost == 1 and name == "METRIC": # and attrs["NAME"]==self.metric:
            #print "attrname: " , attrs["NAME"] , " attr value: " , attrs["VAL"]
            self.allmetrics[self.currhostname][attrs["NAME"]] = attrs["VAL"]

    def end_element(self, name):
            if name == "HOST" and self.inhost==1:
                self.inhost = 0
                self.currhostname = ""


class MonitorVms:
    def __init__(self, monitoring_address, monitoring_port=8649):

        self.ganglia_host = monitoring_address
        self.ganglia_port = monitoring_port

        ## Install logger

        # self.my_logger = get_logger("MonitorVMs", "INFO", logfile=LOG_FILENAME)

        self.allmetrics={}
        self.parser = GParser()
        # initialize parser object. in the refreshMetrics function call the .parse of the
        # parser to update the dictionary object.
        self.refreshMetrics()

    def refreshMetrics(self):
        """
        runs periodically and refreshes the metrics
        :return:
        """
        #self.my_logger.debug("Refreshing metrics from %s:%s" % (self.ganglia_host, self.ganglia_port))
        for res in socket.getaddrinfo(self.ganglia_host, self.ganglia_port, socket.AF_UNSPEC, socket.SOCK_STREAM):
            af, socktype, proto, canonname, sa = res
            self.soc = None
            attempts = 0
            while self.soc is None and attempts < 3:
                attempts += 1
                try:
                    self.soc = socket.socket(af, socktype, proto)
                except socket.error as msg:
                    s = None
                    sleep(1)
                    continue
                try:
                    self.soc.connect(sa)
                except socket.error as msg:
                    self.soc.close()
                    self.soc = None

                    sleep(10)
                    self.my_logger.error("Failed to connect to ganglia endpoint: " + str(self.ganglia_host) + " "+str(msg) + " attempt " + str(attempts) )
                    continue
                break
        if self.soc is None:
            raise Exception('could not open socket %s:%s (%s)' % (str(self.ganglia_host), str(self.ganglia_port), str(msg)))
            sys.exit(1)
        self.allmetrics = None
        f = self.soc.makefile("r")
        try:
            self.allmetrics = self.parser.parse(f)
        except:
            self.my_logger.error("Failed to parse xml from ganglia")
        f.close()
        f = None
        self.soc.close()
        #self.my_logger.debug("REFRESHMETRICS allmetrics: "+str(self.allmetrics))
        return self.allmetrics

    def get_summary(self):
        allmetrics = self.refreshMetrics()
        cpu =0
        mem = 0
        net_in = 0
        net_out = 0
        iops_read = 0
        iops_write = 0
        # pprint(allmetrics["master"].keys())
        for k, v in allmetrics.items():
            cpu += 100-float(v["cpu_idle"])
            mem += 1.0 - float(v["mem_free"])/float(v["mem_total"])
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




def usage():
    print """Usage: check_ganglia \
-h|--host= -m|--metric= -w|--warning= \
-c|--critical= [-s|--server=] [-p|--port=] """
    sys.exit(3)




if __name__ == "__main__":
##############################################################
    ganglia_host = 'master'

    monVms = MonitorVms(ganglia_host)
    interval = 5

    metrics_timeline = []

    def print_out():
        """
        this will be called in case of Ctrl-C or kill signal
        :return:
        """
        print dumps(metrics_timeline)
        exit()

    #install the signal handler
    signal.signal(signal.SIGTERM, lambda a,b: print_out())

    try:
        iterations = 0
        while True:

            metric_values = monVms.get_summary()

            metrics_timeline.append((iterations*interval, metric_values))
            iterations += 1

            sleep(interval)
    except KeyboardInterrupt:
        print_out()

