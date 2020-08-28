#!/usr/bin/env bash
figlet -w 160 -f standard "Run Spark Swarm Worker"

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

figlet -w 160 -f small "Set Swarm Worker status to ready in Vault"
echo `hostname` > .hostname
vault kv put -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/`cat .hostname` status=ready

figlet -w 160 -f small "Get SPARK_SWARM_MANAGER Connection"
while true ; do
  export SPARK_SWARM_MANAGER_STATUS=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_MANAGER | grep -E '^status[ ]*.' | awk '{print $2}'`
  if [ $SPARK_SWARM_MANAGER_STATUS == 'ready' ] ; then
    echo "SPARK_SWARM_MANAGER is ready"
    break
  fi
  if [ $SPARK_SWARM_MANAGER_STATUS == 'running' ] ; then
    echo "SPARK_SWARM_MANAGER is running"
    break
  fi
  sleep 5
done
export SPARK_SWARM_MANAGER_DNS=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_MANAGER | grep -E '^address[ ]*.' | awk '{print $2}'`
echo "SPARK_SWARM_MANAGER is on "$SPARK_SWARM_MANAGER_DNS
export SPARK_SWARM_MANAGER_IP=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_MANAGER | grep -E '^ip[ ]*.' | awk '{print $2}'`
echo "SPARK_SWARM_MANAGER is on "$SPARK_SWARM_MANAGER_IP
export SPARK_SWARM_MANAGER_JOIN_TOKEN=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_MANAGER | grep -E '^join-token[ ]*.' | awk '{print $2}'`
echo "SPARK_SWARM_MANAGER_JOIN_TOKEN is "$SPARK_SWARM_MANAGER_JOIN_TOKEN
export DOCKER_SWARM_IP="`wget -q -O - http://169.254.169.254/latest/meta-data/public-ipv4 || die \"wget public-ipv4 has failed: $?\"`"
test -n "DOCKER_SWARM_IP" || die 'cannot obtain public-ipv4'
echo "DOCKER_SWARM_IP="$DOCKER_SWARM_IP

figlet -w 160 -f small "Make this a Docker Swarm Worker Node"
docker swarm leave --force
docker swarm join --token $SPARK_SWARM_MANAGER_JOIN_TOKEN $SPARK_SWARM_MANAGER_IP:2377 --advertise-addr $DOCKER_SWARM_IP
docker node ls | grep  -oE "\S*\s*\S*\s*`hostname`" | cut -d" " -f1 > .my_node
docker node update --label-add function=spark-worker `cat .my_node`
docker node demote `cat .my_node`

figlet -w 160 -f small "Set Swarm Worker status to joined in Vault"
vault kv put -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/`cat .hostname` status=joined spark_swarm_manager=`echo $SPARK_SWARM_MANAGER_IP:2377`
