#!/usr/bin/env python
__author__ = 'cmantas'
from os import path
import sqlite3


db_file = "results.db"
home = path.dirname(path.realpath(__file__))+"/../"
conn = sqlite3.connect(home+"/"+db_file)

def get_data_size_name(exp_name):
    if "text" in exp_name:
        return "documents"
    elif "synth" in exp_name:
        return "points"
    elif "tfidf" in exp_name:
        return "documents"
    else:
        raise Exception("Do not know the data point for '"+exp_name+"'")

def create_tables():
    global c
    query="CREATE TABLE IF NOT EXISTS {0}\
    (id INTEGER PRIMARY KEY AUTOINCREMENT, {1} INTEGER, {2} INTEGER, time INTEGER, date TIMESTAMP);"

    q = query.format("mahout_kmeans_text", "documents", "k")
    c.execute(q)
    q = query.format("weka_kmeans_text", "documents", "k")
    c.execute(q)
    q = query.format("mahout_kmeans_synth", "points", "k")
    c.execute(q)
    q = query.format("weka_kmeans_synth", "points", "k")
    c.execute(q)
    conn.commit()


def store(table, data):
    keys = "("
    values = "("
    for k, v in data.iteritems():
        keys += k + ", "
        values += v + ", "
    keys += "date)"
    values += "current_timestamp)"

    statement = "INSERT INTO {0}{1} VALUES {2};".format(table, keys, values)
    c.execute(statement)