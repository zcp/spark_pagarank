1. create docker machines
docker-machine create -d kvm docker-manager
docker-machine create -d kvm docker-worker

2. show docker machines' status.
docker-machine ls

3. start manager node
docker-machine ssh docker-manager "docker swarm init --advertise-addr <manager ip>"

4. add worker nodes to swarm
docker-machine ssh docker-worker "docker swarm join \
--token <token> \
<manager ip>:2377"

5. show  nodes in swarm
docker-machine ssh docker-manager  "docker node ls"

#deploy a spark app on swarm
6. show environment variables on docker-manager host
docker-machine env docker-manager
#set such variables on local host
 eval $(docker-machine env docker-manager)

7. deploy a spark app 
#docker-compose.yml comes from spark-docker-swarm and modify its version 3.5 to 3.0
export EXTERNAL_IP=$(docker-machine ip docker-worker)
docker-machine ssh docker-manager "docker stack deploy -c docker-compose.yml spark"

8.scale workers
 #docker service scale service-name_worker (service-name=spark in the example)
 docker service scale spark_worker=3

9. show spark master and workers
docker stack ps spark

10. access spark running homepage by browser on local host:
http://192.168.42.66:8080/ where 192.168.42.66 is docker-manager's ip

11. run the spark app
    #get container ID which runs spark master
   docker-machine ssh docker-manager "docker ps --filter name=master --format {{.ID}}"
  docker cp count.py $CONTAINER_ID:/tmp

  docker exec $CONTAINER_ID \
  bin/spark-submit \
    --master spark://master:7077 \
    --class endpoint \
    /tmp/count.py

12 shutdown docker machines
   docker-machine stop docker-manager
   docker-machine stop docker-worker

13. remove environment variables on local host.
 eval $(docker-machine env -u)

