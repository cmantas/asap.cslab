__author__ = 'cmantas'
import sqlite3
conn = sqlite3.connect('../results.db')
c = conn.cursor()

def get_data_size_name(exp_name):
    if "text" in exp_name:
        return "documents"
    elif "synth" in exp_name:
        return "points"
    else:
        raise Exception("Do not know the data point for"+exp_name)

def get_experiment(exp_name, k=None):
    data_name = get_data_size_name(exp_name)

    if k is None:
        query = "SELECT {0}, AVG(time) FROM {1} GROUP BY {0}".format(data_name, exp_name)
    else :
        query = "SELECT {0}, time FROM {1} WHERE k={2} ORDER BY {0}".format(data_name, exp_name,k)
    print query
    for row in c.execute(query):
        print row

get_experiment("weka_kmeans_synth", 21)