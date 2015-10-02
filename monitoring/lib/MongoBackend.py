__author__ = 'cmantas'
import datetime
from ConsoleBackend import ConsoleBackend
from lib.tools import myplot, show, mycast
from pymongo import MongoClient





def cast_dict(a):
    """
    given a dictionary of string-->string, it creates another dictionary with the same keys and the casted values of
    the original as its values values
    :param a: a dictionary of string-->string
    :return:
    """
    return dict(map(lambda (k, v): (k,mycast(v)), a.iteritems()))


class MongoBackend(ConsoleBackend):
    def __init__(self, host='localhost', port=27017):

        # set defaults again
        if host is None:
            self.host='localhost'
        else:
            self.host=host
        if port is None:
            self.port=27017
        else:
            self.port = int(port)

        self.client = MongoClient(self.host, self.port)
        # using the metrics db
        self.db = self.client.metrics

    def _get_collection(self, collection):
        return eval("self.db.{0}".format(collection))

    def query(self, experiment, query, tupples=True):
        dict_result = self.dict_query(experiment, query)
        return map(lambda d:d.values(), dict_result)


    def dict_query(self, experiment, query):
        q = eval(query)
        if type(q) is tuple:
            selection = q[0]
            projection = q[1]
        elif type(q) is dict:
            selection = q
            projection = None
        else:
            raise Exception("I cannot handle that kind of query: "+str(type(q)))
        return self.find(experiment, selection, projection)

    def report(self, experiment_name, **kwargs):
        # cast the dict values into their respective types
        casted = cast_dict(kwargs)
        # using the experiment name as a collection
        metrics = eval("self.db.{0}".format(experiment_name))
        r = metrics.insert_one(casted)

    def find(self, experiment, selection={}, projection=None, tuples=True):
        collection = self._get_collection(experiment)
        rows = collection.find(selection, projection)
        if tuples: return tuple(rows)
        else: return rows

    def __str__(self):
        return "MongoBackend({0},{1})".format(self.host, self.port)

    def plot_query(self, experiment, query, **kwargs):
        rows = self.query(experiment, query)

        # transpose the rows
        rows_transposed = zip(*rows)

        # plot the result
        myplot(*rows_transposed, **kwargs)
        show()
        return rows_transposed


