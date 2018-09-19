#!/bin/bash

create_nodes(){
  # Creating 3 nodes 
  echo "### Creating nodes ..."
  for c in {1..3} ; do
     docker-machine create -d kvm node$c
  done

  # Get IP from leader node1
  leader_ip=$(docker-machine ip node1)

  # Init Docker Swarm mode
  echo "### Initializing Swarm mode ..."
  eval $(docker-machine env node1)
  docker swarm init --advertise-addr $leader_ip

  # Swarm tokens
  #manager_token=$(docker swarm join-token manager -q)
  worker_token=$(docker swarm join-token worker -q)
  '''
  # Joinig manager nodes
  echo "### Joining manager modes ..."
  for c in {2..3} ; do
     eval $(docker-machine env node$c)
     docker swarm join --token $manager_token $leader_ip:2377
  done
  '''

  # Join worker nodes
  echo "### Joining worker modes ..."
  for c in {2,3} ; do
     eval $(docker-machine env node$c)
     docker swarm join --token $worker_token $leader_ip:2377
  done
}

#create_nodes

# Clean Docker client environment
#echo "### Cleaning Docker client environment ..."
#eval $(docker-machine env -u)

deploy_app(){
   #let docker host can access network by local host network
   
   eval $(docker-machine env node1)
  
   docker-machine scp docker-compose.yml node1:/home/docker
  
   for c in {1,2,3}; do
      #docker-machine ssh node$c "cd /home/docker; mkdir spark_config; mkdir spark-events; chmod 777 spark-events"
      docker-machine scp -r /home/zcp/spark_pagerank node$c:/home/docker
      #docker-machine scp spark-defaults.conf node$c:/home/docker/spark_config
      #docker-machine scp log4j.properties node$c:/home/docker/spark_config
      #docker-machine scp -r conf/
      #docker-machine scp pagerank.py node$c:/home/docker
      #docker-machine scp url_data node$c:/home/docker
   done
 
   docker-machine ssh node1 "cd /home/docker/spark_pagerank; docker stack deploy -c docker-compose.yml spark-pagerank"
   docker-machine ssh node1 "docker service scale spark-pagerank_worker=2"
   
   spark_master_id=$(docker-machine ssh node1 "docker ps --filter name=master --format {{.ID}}")
   echo $spark_master_id
   #docker-machine ssh node1 "docker exec $spark_master_id mkdir /tmp/spark-events"
   #docker-machine ssh node1 "docker exec $spark_master_id sbin/start-history-server.sh"
   docker-machine ssh node1 "docker exec $spark_master_id bin/spark-submit --master spark://master:7077 /tmp/code/pagerank.py /tmp/data/url_data 2"
   
}

deploy_app

start_nodes(){
   # Start nodes
   echo "### Starting nodes ..."
   for c in {1..6} ; do
       docker-machine start node$c
   done

   # Clean Docker client environment
   echo "### Cleaning Docker client environment ..."
   eval $(docker-machine env -u)
}

remove_nodes(){
   # Clean Docker client environment
   echo "### Cleaning Docker client environment ..."
   eval $(docker-machine env -u)

   # Remove nodes
   echo "### Removing nodes ..."
   for c in {1..6} ; do
       docker-machine rm node$c --force
   done
}
 
