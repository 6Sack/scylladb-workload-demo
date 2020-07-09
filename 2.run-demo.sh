#!/bin/bash
set -e
set -x

echo "starting demo..."
echo

cd ~/scylladb-workload-demo/scylladb-docker
#create model
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "CREATE KEYSPACE workload WITH replication = {'class': 'SimpleStrategy', 'replication_factor':3};"
sleep 3

#create roles
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "create ROLE loader1 with SUPERUSER = true AND LOGIN = true and PASSWORD = '123456';"
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "create ROLE analytics1 with SUPERUSER = true AND LOGIN = true and PASSWORD = '123456';"
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "create ROLE web1 with SUPERUSER = true AND LOGIN = true and PASSWORD = '123456';"
sleep 3

#create service levels
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "CREATE SERVICE_LEVEL OLAP WITH SHARES = 1000;"
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "CREATE SERVICE_LEVEL PIPELINE WITH SHARES = 1000;"
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "CREATE SERVICE_LEVEL SERVICE WITH SHARES = 1000;"
sleep 3

#attach service levels to roles
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "ATTACH SERVICE_LEVEL OLAP TO analytics1;"
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "ATTACH SERVICE_LEVEL pipeline TO loader1;"
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "ATTACH SERVICE_LEVEL service TO web1;"
sleep 3
cd ~/

cd ~/scylladb-workload-demo/scylladb-samples/scylladb-workload-prioritization/
#run insert/loader worker
GOMAXPROCS=8 ./go-workoad-prioritization-scylla-demo-linux --workers 4 --iterations 10 --benchmarks insert --cluster "172.17.0.1:9042" --port 9009 --connections 2 -rf 1 --username loader1 --password 123456 > insert.log 2>&1 &

#run scan/analytic worker
GOMAXPROCS=8 ./go-workoad-prioritization-scylla-demo-linux --workers 1 --iterations 1000 --benchmarks select --cluster "172.17.0.1:9042" --port 9010 --connections 2 -rf 1 --username analytics1 --password 123456 > select.log 2>&1 &

#run get/service worker
GOMAXPROCS=8 ./go-workoad-prioritization-scylla-demo-linux --workers 2 --iterations 1 --benchmarks get --cluster "172.17.0.1:9042" --port 9011 --connections 2 -rf 1 --username web1 --password 123456 > get.log 2>&1 &

echo
echo "done."


