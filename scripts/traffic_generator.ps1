while ($true) { 
    curl http://localhost:5000 | Out-Null
    curl http://localhost:5000/api/data | Out-Null
    curl http://localhost:5000/api/slow | Out-Null
    Start-Sleep -Seconds 2
}
