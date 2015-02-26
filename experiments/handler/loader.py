import sqlite3
conn = sqlite3.connect('../results.db');
from os import listdir
from tokenize import generate_tokens



def handle_line(line):
    tokens = generate_tokens(line)
    s = line.split(":")
    exp_name = s[0]
    data = s[1].split(',')
    for r in data:
        key = r.split()[0].strip()
        value= r.split()[1].strip()
        print key, value


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