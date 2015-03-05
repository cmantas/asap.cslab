#!/usr/bin/env python
__author__ = 'cmantas'

from os import system
from sys import stdout
import logging
from time import time
from lib.db import *
from lib.my_logging import get_logger



log = get_logger("EXPERIMENT")

commands= {
    "weka_kmeans_synth": "java -jar ~/bin/lib/kmeans_weka.jar_text_weka.sh %d %d"
}


def run_command(command, operator_output=None):
    out = ""
    if not operator_output is None:
        out = " > "+operator_output

    start_time = int(round(time() * 1000))
    system(command+out)
    end_time = int(round(time() * 1000))
    duration = float(end_time - start_time)/1000
    print "took",duration , "sec"
    return duration


def run_parameter_experiment(exp_name, parameters, output):
    log.info(exp_name)