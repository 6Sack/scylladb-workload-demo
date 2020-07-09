#!/bin/bash
set -e
set -x

#scylla cluster
cd ~/scylladb-workload-demo/scylladb-docker
sudo docker-compose -p scylla down --remove-orphans
cd ~/
