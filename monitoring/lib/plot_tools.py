__author__ = 'cmantas'
import matplotlib.pyplot as plt

import  sqlite3

try:
    plt.style.use('fivethirtyeight')
except:
    print "You could get prettier graphs with matplotlib > 1.4"


from matplotlib.pyplot import figure, show


def myplot(*args, **kwargs):
    if "title" in kwargs:
        title = kwargs["title"]
        del(kwargs["title"])
        plt.title(title)
    if "xlabel" in kwargs:
        xlabel = kwargs["xlabel"]
        del(kwargs["xlabel"])
        plt.xlabel(xlabel)
    if "ylabel" in kwargs:
        ylabel = kwargs["ylabel"]
        del(kwargs["ylabel"])
        plt.ylabel(ylabel)
    plt.grid(True)
    # plt.grid(which='both')
    # plt.grid(which='minor', alpha=0.2)
    plt.plot(*args, **kwargs)
    plt.legend(loc = 'upper left')




# def multi_graph(table, x, y, cond_list, groupBy="", where="", **kwargs):
#
#     if 'title' not in kwargs:
#         kwargs['title'] = x+" vs "+y
#     if 'xlabel' not in kwargs:
#         kwargs['xlabel'] = x
#     if 'ylabel' not in kwargs:
#         kwargs['ylabel'] = y
#     if groupBy != "":
#         groupBy = "group by "+groupBy
#     if where !="":
#         where = where+" and "
#
#
#
#     # for c in cond_list:
#     #     query = "select {0} from {1} where {2} {3}".format(x+','+y, table, c, groupBy)
#     #     rx, ry = query2lists(query)
#     #     myplot(rx,ry, label=c, title=title, xlabel=xlabel, ylabel=ylabel)
#     # show()
#     query = "select {0} from {1} where {2}".format(x+","+ y, table, where) + "{0} " + groupBy
#     multi_graph_query(query, cond_list, **kwargs)


# def multi_graph_query(query, cond_list, **kwargs):
#     figure()
#     for c in cond_list:
#         queryf = query.format(c)
#         rx, ry = query2lists(queryf)
#         myplot(rx,ry, label=c, **kwargs)

