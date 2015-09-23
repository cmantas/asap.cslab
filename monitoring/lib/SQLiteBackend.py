__author__ = 'cmantas'
from sqlite3 import connect
from json import dumps, dump, load
from os.path import isfile
from plot_tools import myplot, show
from ConsoleBackend import ConsoleBackend


class SQLiteBackend(ConsoleBackend):
    def __init__(self, sql_file):
        self.file=sql_file
        self.connection = connect(self.file)
        self.cursor = self.connection.cursor()

        #aliases
        self.commit= self.connection.commit
        self.execute = self.cursor.execute

    # def analyze_schema(self):
    #     # for row in sqll.cursor.execute("PRAGMA table_info([test]);"):
    #     # print row
    #     return

    def report(self, experiment_name, **kwargs):
        print "reporting to sqlite"
        key_string="( "
        value_string="( "
        for k, v in kwargs.iteritems():
            key_string += str(k) + ","
            value_string+=str(v) + ","
        key_string = key_string[:-1] + ')'
        value_string = value_string[:-1]+')'
        query = 'INSERT INTO '+ experiment_name+key_string + " VALUES "+ value_string
        #print query
        try:
            self.execute(query)
            self.commit()
        except:
            print "Query failed!"
            print "query was: "+query

    def query(self, query, tupples=True):
        rows = self.execute(query)
        # return rows as tupple(list) rather than
        if tupples: return tuple(rows)
        else: return rows



    @staticmethod
    def dict_factory(cursor, row):
        d = {}
        for idx, col in enumerate(cursor.description):
            d[col[0]] = row[idx]
        return d

    def plot_query(self, query, **kwargs):
        rows = self.query(query)

        # transpose the rows
        rows_transposed = zip(*rows)

        # plot the result
        myplot(*rows_transposed, **kwargs)
        show()
        return rows_transposed

    def dict_query(self, query):
        # a factory from rows-->dict
        rows =tuple(self.query(query))
        # r= rows.fetchone()
        # return self.dict_factory(self.cursor, rows[0])
        return map(lambda t:self.dict_factory(self.cursor, t), rows)

    def  __str__(self):
        return super(SQLiteBackend, self).__str__() + "({0})".format(self.file)





