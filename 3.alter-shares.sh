#!/bin/bash
set -e
set -x

echo "starting demo..."
echo

cd ~/scylladb-workload-demo/scylladb-docker
#list share levels
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "LIST ALL SERVICE_LEVELS;"
#alter insert/loader shares
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "ALTER SERVICE_LEVEL pipeline  WITH SHARES = 10;"
sleep 3
#alter scan/analytics shares
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "ALTER SERVICE_LEVEL OLAP  WITH SHARES = 100;"
sleep 3
#alter scan/analytics shares
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "ALTER SERVICE_LEVEL service  WITH SHARES = 1000;"
sleep 3
#list share levels
sudo docker-compose -p scylla exec scylladb-node1 cqlsh -u cassandra -p cassandra -e "LIST ALL SERVICE_LEVELS;"
cd ~/

echo
echo "done."