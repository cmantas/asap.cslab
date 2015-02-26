import sqlite3
conn = sqlite3.connect('../results.db');
from os import listdir
from tokenize import generate_tokens


def store_experiment:
    

def handle_line(line):
    tokens = generate_tokens(line)
    s = line.split(":")
    exp_name = s[0]
    r = s[1].split(',')
    size = r[0].split()[1]
    k = r[1].split()[1]
    time = r[2].split()[0]
    print exp_name, size, k , time



resultsdir = "../results"

resultfiles = [f for f in listdir(resultsdir) if f.endswith(".results")]
print resultfiles
c = conn.cursor()

for f in resultfiles:
    with open(resultsdir+"/"+f) as file:
        for line in file.readlines():
            handle_line(line)



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