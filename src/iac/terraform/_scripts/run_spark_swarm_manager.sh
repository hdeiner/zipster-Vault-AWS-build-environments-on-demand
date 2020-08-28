#!/usr/bin/env bash
figlet -w 160 -f standard "Run Spark Swarm Manager"

figlet -w 160 -f small "Get Vault Connection"
export ENVIRONMENT=$(<.environment)
export VAULT_ADDRESS="http://"$(<.vault_dns)":8200"
mkdir .vault_howardeiner
aws s3 cp s3://zipster-aws-on-demand-vault/root_token .vault_howardeiner/root_token
export VAULT_TOKEN=$(<.vault_howardeiner/root_token)
vault login -address=$VAULT_ADDRESS $VAULT_TOKEN > /dev/null

figlet -w 160 -f small "Get MYSQL Instance Connection"
while true ; do
  export MYSQL_STATUS=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/MYSQL | grep -E '^status[ ]*.' | awk '{print $2}'`
  if [ $MYSQL_STATUS == 'running' ] ; then
    echo "MySQL is running"
    break
  fi
  sleep 5
done
export MYSQL_DNS_NAME=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/MYSQL | grep -E '^address[ ]*.' | awk '{print $2}'`
export MYSQL_USER=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/MYSQL | grep -E '^user[ ]*.' | awk '{print $2}'`
export MYSQL_PASSWORD=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/MYSQL | grep -E '^password[ ]*.' | awk '{print $2}'`

figlet -w 160 -f small "Initialize Swarm Cluster"
export DOCKER_SWARM_DNS_NAME="`wget -q -O - http://169.254.169.254/latest/meta-data/public-hostname || die \"wget public-hostname has failed: $?\"`"
test -n "DOCKER_SWARM_DNS_NAME" || die 'cannot obtain public-hostname'
echo "DOCKER_SWARM_DNS_NAME="$DOCKER_SWARM_DNS_NAME
export DOCKER_SWARM_IP="`wget -q -O - http://169.254.169.254/latest/meta-data/public-ipv4 || die \"wget public-ipv4 has failed: $?\"`"
test -n "DOCKER_SWARM_IP" || die 'cannot obtain public-ipv4'
echo "DOCKER_SWARM_IP="$DOCKER_SWARM_IP
docker swarm leave --force
docker swarm init --advertise-addr $DOCKER_SWARM_IP
docker node ls | grep  -oE "\S*\s*\S*\s*`hostname`" | cut -d" " -f1 > .my_node
docker node update --label-add function=spark-manager `cat .my_node`

figlet -w 160 -f small "Get Cluster Join Tokens"
docker swarm join-token manager | grep  -oE "\s+docker\s+swarm\s+join\s+\-\-token\s*\S*" | cut -d" " -f9 > /home/ubuntu/.join-token

figlet -w 160 -f small "Set Swarm Join Tokens in Vault"
vault kv put -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_MANAGER address=$DOCKER_SWARM_DNS_NAME ip=$DOCKER_SWARM_IP join-token=`cat /home/ubuntu/.join-token` status=ready

figlet -w 160 -f small "Wait for swarm workers to join"
export AWS_REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
echo AWS_REGION=$AWS_REGION
export SWARM_WORKER_COUNT=`expr $(aws ec2 describe-instances --region $AWS_REGION --filters "Name=tag:Name,Values=AWSQA-SWARM Spark Swarm Worker*" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" | wc -l) - 2` # don't count []
echo SWARM_WORKER_COUNT=$SWARM_WORKER_COUNT
while true;
 do
    export VAULT_SWARM_WORKER_COUNT=$(vault kv list -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/ | tail -n+3 | wc -l)
    if [ $VAULT_SWARM_WORKER_COUNT == $SWARM_WORKER_COUNT ]
    then
      break
    else
      echo "Waiting for ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/ to have $SWARM_WORKER_COUNT instances (has $VAULT_SWARM_WORKER_COUNT now)"
    fi
    sleep 5
  done
for path in $(vault kv list -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/ | tail -n+3);
  do
    echo evaluate ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/${path}
    export VAULT_SWARM_WORKER_STATUS=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT//SPARK_SWARM_WORKER/${path} | grep -E '^status[ ]*.' | awk '{print $2}'`
    if [ $VAULT_SWARM_WORKER_STATUS == 'ready' ] ; then
      echo "ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/${path} is ready"
      break
    fi
    if [ $VAULT_SWARM_WORKER_STATUS == 'joined' ] ; then
      echo "ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/${path} is joined"
      break
    fi
    sleep 5
  done

#figlet -w 160 -f small "Make this node manager only"
#docker node ls | grep  -oE "\S+\s\*" | cut -d" " -f1 > /home/ubuntu/.manager_node
#docker node update --availability drain `cat /home/ubuntu/.manager_node`

figlet -w 160 -f small "Deploy Spark Application to swarm"
env VAULT_TOKEN=$VAULT_TOKEN VAULT_ADDRESS=$VAULT_ADDRESS ENVIRONMENT=$ENVIRONMENT MYSQL_DNS_NAME=$MYSQL_DNS_NAME MYSQL_USER=$MYSQL_USER MYSQL_PASSWORD=$MYSQL_PASSWORD docker stack deploy --compose-file use_spark_swarm.yml spark_swarm

figlet -w 160 -f small "Publish 8080 port for spark swarm workers"
docker service update --publish-add published=8080,target=8080 spark_swarm_spark_service

figlet -w 160 -f small "Deploy Portainer"
docker stack deploy --compose-file=use_portainer_swarm.yml portainer_swarm

figlet -w 160 -f small "Update Vault for portainer running"
vault kv put -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/PORTAINER address=$DOCKER_SWARM_DNS_NAME ip=$DOCKER_SWARM_IP status=running port=9000

figlet -w 160 -f small "Deploy Swarmprom"
tar -xf swarmprom.tar
mv swarmprom/* .
rm -rf swarmprom/
env ADMIN_USER=admin ADMIN_PASSWORD=password docker stack deploy --compose-file=use_swarmprom_swarm.yml swarmprom_swarm

figlet -w 160 -f small "Update Vault for Grafana running"
vault kv put -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/GRAFANA address=$DOCKER_SWARM_DNS_NAME ip=$DOCKER_SWARM_IP status=running port=3000

figlet -w 160 -f small "Update Vault for Prometheus running"
vault kv put -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/PROMETHEUS address=$DOCKER_SWARM_DNS_NAME ip=$DOCKER_SWARM_IP status=running port=9090

figlet -w 160 -f small "Wait for Spark to start"
while true ; do
  result=$(curl http://localhost:8080/zipster -d '{"radius":"2.0", "zipcode":"07440"}' 2>&1 | grep -E "NA-US-NJ-WAYNE" | wc -l)
  if [ $result != 0 ] ; then
    echo "Spark Swarm is started"
    break
  fi
  echo "Waiting for Spark Swarm to start"
  sleep 5
done

figlet -w 160 -f small "Update Vault for swarm manager running"
vault kv put -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_MANAGER address=$DOCKER_SWARM_DNS_NAME ip=$DOCKER_SWARM_IP join-token=`cat /home/ubuntu/.join-token` status=running
