#!/bin/bash
set -e
set -x

echo "starting..."
echo

sudo setenforce 0
sudo mkdir -p /var/lib/scylla/data /var/lib/scylla/commitlog

sleep 1

#scylla cluster
cd ~/scylladb-workload-demo/scylladb-docker
sudo docker-compose -p scylla up -d
sleep 3
sudo docker-compose -p scylla logs scylladb-node1
sleep 60
sudo docker-compose -p scylla exec scylladb-node1 nodetool status || echo
cd ~/

sleep 30

cd ~/scylladb-workload-demo/scylladb-docker
sudo docker-compose -p scylla exec scylladb-node1 nodetool status || echo
cd ~/

echo
echo "done."