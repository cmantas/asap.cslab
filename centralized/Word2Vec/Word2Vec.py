__author__ = 'gsvic'

"""
Word2Vec Operator
Args
1) Input Path

Run: python Word2Vec.py $INPUT_PATH
"""

import gensim
import os, sys, time

if __name__ == "__main__":
    args = sys.argv
    path = args[1]

    docs = []
    files = os.listdir(path)

    for f in files:
        with open(path+f) as inDoc:
            docs.append( [ token for token in inDoc.read().split()] )

    start = time.time()
    model = gensim.models.Word2Vec(docs)

    execTime = time.time() - start
    operator = "Word2Vec_Gensim"
    size = len(files)

    output = dict({"operator": operator, "exec_time": execTime, "size": size})

    print output