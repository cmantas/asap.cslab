awk '{print $1}' web-Stanford.txt > web-Stanford_nodes.txt
sed -i '1,4d' web-Stanford_nodes.txt

awk '{print $2}' web-Stanford.txt > web-Stanford_nodes_tmp.txt
sed '1,4d' web-Stanford_nodes_tmp.txt>> web-Stanford_nodes.txt
rm web-Stanford_nodes_tmp.txt;

sort -u -n web-Stanford_nodes.txt > web-Stanford_nodes2.txt
