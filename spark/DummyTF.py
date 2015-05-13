#!/usr/bin/env python
__author__ = 'cmantas'

from os import listdir
from os.path import isfile, join

class DummyTF(object):

    def __init__(self):
        self.term_count=0
        self.doc_count = 0
        self.dictionary={}
        self.term_frequencies={}
        self.tf_vectors = []

    def add(self, term, doc_dir):

        tid=-1
        #check if term in global dicts
        if term not in self.dictionary:
            self.term_count +=1
            tid = self.term_count
            self.dictionary[term]=self.term_count
            self.term_frequencies[self.term_count] = 1
        else:
            tid = self.dictionary[term]
            self.term_frequencies[tid] += 1
        #add to document dicts (tf vectors)
        if tid not in doc_dir:
            doc_dir[tid] = 1
        else:
            doc_dir[tid] += 1

    def add_line(self, line, doc_dir):
        for i in line.split():
            self.add(i, doc_dir)

    def add_document(self, doc, lines):
        doc_dir = {}
        self.doc_count += 1
        for line in lines:
            self.add_line(line, doc_dir)
        self.tf_vectors.append(doc_dir)

    def read_directory(self, dirname):
        files = [ f for f in listdir(dirname) if isfile(join(dirname,f)) ]
        for fname in files:
            doc = dirname+"/"+fname
            print doc
            with open(doc) as f:
                lines = f.readlines()
                self.add_document(doc, lines)

    def export_term_frequences(self):
        rv={}
        for k,v in self.term_frequencies.itervalues():
            t = self.dictionary


dtf = DummyTF()

dtf.read_directory("/home/cmantas/Data/docs_virt_dir/text/")

print dtf.dictionary

for tfv in dtf.tf_vectors:
    print tfv