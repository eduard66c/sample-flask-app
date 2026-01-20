while true; do 
    curl -s http://localhost:5000 > /dev/null
    curl -s http://localhost:5000/api/data > /dev/null
    curl -s http://localhost:5000/api/slow > /dev/null
    sleep 2
done
