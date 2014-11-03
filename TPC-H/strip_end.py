#! /usr/bin/env python
__author__ = 'cmantas'
import subprocess
from  os import system


fname = "../customer_small.tbl"

from os import listdir
from os.path import isfile, join

copy_command = "\copy %s from '%s' with delimiter as '|';"
shell_command = "echo \"%s\" | psql -U asap asap\n"

all_commands = []
tables = []

table_filenames = [ f for f in listdir(".") if (isfile(f) and f.endswith(".tbl") and not f.endswith("strip.tbl")) ]

for tfile in table_filenames:
    new_filename = tfile[:-4] + "_strip.tbl"
    table_name = tfile.split(".")[0].split("_")[0]
    print table_name
    all_commands.append( copy_command %(table_name, new_filename) )
    tables.append(table_name)

    print "Stripping: " + tfile + " ",
    with open(tfile) as f:
        fstrip = file(new_filename, "w+")
        for line in f:
            line = line[:-2]+"\n"
            fstrip.write(line)
        fstrip.close()

    print "OK"

with open("load_comands.sh", "w+") as f:
    for c in all_commands:
        f.write(shell_command%c)

