#!/usr/bin/env python
__author__ = 'cmantas'

import requests, codecs
from json import loads
from threading import Thread
from os import mkdir
from sys import argv, stderr

#default values
total = 2
window = 1000
stream = True


proxies = None

windows_counter = 0
docs_counter = 0


## read input params
try:
    i = argv.index("window")
    window = int(argv[i+1])
except: pass;
try:
    i = argv.index("total")
    total = int(argv[i+1])
    if total < window:
        window = total
except: pass;
try:
    i = argv.index("output")
    output_dir = argv[i+1]
    stream = False
except: pass;
try:
    i = argv.index("proxy")
    proxies = {"http": argv[i+1]}
except: pass;


# if not streaming output, create output dir
if "stream" in argv:
    stream = True
else:
    try: mkdir(output_dir)
    except: pass


def process_and_write(text):
    global windows_counter, docs_counter
    r_dict = loads(text)
    hits = r_dict['hits']['hits']
    text = ""
    #get contents
    for d in hits:
        docs_counter += 1
        title = d['_source']['textTitle']
        content = d['_source']["textContent"]
        text += "%s\n%s\n" % (title, content)
    if stream:
        print text.encode("utf-8")
        pass
    else:
        file = codecs.open(output_dir+"/"+str(windows_counter), "w+", "utf-8")
        file.write(text)
        file.close()
    windows_counter += 1


## Iterate and fetch the documents
current = 0; writer_thread = None
while current<total:
    if window>(total-current): window=(total-current)
    payload = {'q': '*', 'pretty': "true", "size": window, "from": current}
    current += window

    r = requests.get("http://imr41.internetmemory.org:9200/europeannews/resource/_search",
                     params=payload, proxies=proxies)

    ###################### async write to disk ######################
    #join the prev writer thread
    if writer_thread != None: writer_thread.join()
    writer_thread=Thread(target=process_and_write, args=(r.text,))
    writer_thread.start()


#join active thread
if writer_thread != None:writer_thread.join()

#DONE
stderr.write("DONE reading "+str(docs_counter)+" docs in "+str(windows_counter)+" iterations \n")
