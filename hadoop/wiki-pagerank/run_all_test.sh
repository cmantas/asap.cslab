iterations=10

hadoop jar target/*.jar Main input/wikipedia output/wiki_pagerank $iterations 2>/dev/null
echo "===== TAIL  ====="
hcat output/wiki_pagerank/* | tail -n 3 
echo "===== HEAD  ====="
hcat output/wiki_pagerank/* | head -n 3 
