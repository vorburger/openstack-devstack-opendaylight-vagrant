set -x -e
curl -u admin:admin --header Content-Type:application/json --data @daexim-immediate-import-POST.json http://localhost:8181/restconf/operations/data-export-import:immediate-import
