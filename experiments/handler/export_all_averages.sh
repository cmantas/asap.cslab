#!/bin/bash
sqlite3 ../results.db <<!
.headers on
.mode csv
.output weka_kmeans_synth.csv
select points, k, avg(time)from weka_kmeans_synth group by points,k;
!
