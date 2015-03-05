#!/usr/bin/env python
__author__ = 'cmantas'
import logging
from sys import stdout

configured_loggers = []
def get_logger(name, level='INFO', show_level=False, show_time=True, logfile=None):
    new_logger = logging.getLogger(name)
    #skip configuration if already configured
    if name in configured_loggers:
        return new_logger

    new_logger.setLevel(logging.DEBUG)

    console_handler = logging.StreamHandler(stdout)

    #construct format
    console_format = '%(name)10s: %(message)s'
    if show_level: console_format = '[%(levelname)s] ' + console_format
    if show_time: console_format = console_format+'\t\t| %(asctime)-15s'
    formatter = logging.Formatter(console_format, "%b%d %H:%M:%S")

    #add console handler
    console_handler.setFormatter(formatter)
    eval("console_handler.setLevel(logging.%s)" % level)
    new_logger.addHandler(console_handler)

    #Different handler for logfile
    if not logfile is None:
        file_handler = logging.FileHandler(logfile)
        file_handler.setLevel(logging.DEBUG)
        fformat = '%(asctime)-15s[%(levelname)5s] %(name)20s: %(message)s'
        fformatter = logging.Formatter(fformat, "%b%d %H:%M:%S")
        file_handler.setFormatter(fformatter)
        #print "adding handler for %s" % logfile
        new_logger.addHandler(file_handler)

    new_logger.propagate = False
    #logging.root.disabled = True
    configured_loggers.append(name)
    return new_logger