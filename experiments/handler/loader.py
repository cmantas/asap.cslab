import sqlite3
conn = sqlite3.connect('../results.db');
from os import listdir


def create_tables():
    global c
    query="CREATE TABLE IF NOT EXISTS {0}\
    (id INTEGER PRIMARY KEY AUTOINCREMENT, {1} INTEGER, {2} INTEGER, time INTEGER, date TIMESTAMP);"

    c.execute(query.format("mahout_kmeans_text", "documents", "k"))
    c.execute(query.format("weka_kmeans_text", "documents", "k"))
    c.execute(query.format("mahout_kmeans_synth", "points", "k"))
    c.execute(query.format("weka_kmeans_synth", "points", "k"))
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

def handle_line(line):
    s = line.split(":")
    exp_name = s[0]
    data = {}
    for r in s[1].split(','):
        key = r.split()[0].strip()
        value = r.split()[1].strip()
        data[key] = value
    store(exp_name, data)

c = conn.cursor()

resultsdir = "../results"

resultfiles = [f for f in listdir(resultsdir) if f.endswith(".results")]
print resultfiles

create_tables()

for f in resultfiles:
    with open(resultsdir+"/"+f) as file:
        for line in file.readlines():
            handle_line(line)
        conn.commit()



c.execute('SELECT * FROM mahout_kmeans_text')
print c.fetchone()




# # Create table
# c.execute('''CREATE TABLE stocks
#              (date text, trans text, symbol text, qty real, price real)''')
#
# # Insert a row of data
# c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")
#
# # Save (commit) the changes
# conn.commit()

# We can also close the connection if we are done with it.
# Just be sure any changes have been committed or they will be lost.
conn.close()