set -x
rm -v ../../../git/netvirt/vpnservice/distribution/karaf/target/assembly/daexim/*
curl -u admin:admin --header Content-Type:application/json --data @daexim-schedule-export-POST.json http://localhost:8181/restconf/operations/data-export-import:schedule-export
# Could use Daexim status API to see when it's done...
sleep 5
# cat ../../../git/netvirt/vpnservice/distribution/karaf/target/assembly/daexim/odl_backup_config.json | python -mjson.tool >  config.json
# cat ../../../git/netvirt/vpnservice/distribution/karaf/target/assembly/daexim/odl_backup_operational.json | python -mjson.tool >  op.json
