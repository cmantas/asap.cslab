echo "\copy part from 'part_strip.tbl' with delimiter as '|';" | psql -U asap asap
echo "\copy supplier from 'supplier_strip.tbl' with delimiter as '|';" | psql -U asap asap
echo "\copy orders from 'orders_strip.tbl' with delimiter as '|';" | psql -U asap asap
echo "\copy nation from 'nation_strip.tbl' with delimiter as '|';" | psql -U asap asap
echo "\copy partsupp from 'partsupp_strip.tbl' with delimiter as '|';" | psql -U asap asap
echo "\copy region from 'region_strip.tbl' with delimiter as '|';" | psql -U asap asap
