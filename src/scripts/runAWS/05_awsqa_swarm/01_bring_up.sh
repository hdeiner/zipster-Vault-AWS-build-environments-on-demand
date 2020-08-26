#!/usr/bin/env bash

figlet -w 200 -f standard "Bring Up AWS-QA-SWARM Environment"

export ENVIRONMENT=AWS-QA-SWARM

figlet -w 200 -f small "Terraform AWS-QA-SWARM Environment"
cd ../../iac/docker-compose/artifacts/swarmprom
tar -zcf /tmp/swarmprom.tar .
cd -

cd ../../iac/terraform/awsqa_swarm
terraform apply -var environment=$ENVIRONMENT -auto-approve
echo `terraform output spark_swarm_manager_dns | grep -o '".*"' | cut -d '"' -f2` > .spark_swarm_manager_dns
cd -

export VAULT_ADDRESS="http://"$(<../../iac/terraform/vault/.vault_dns)":8200"
echo "VAULT_ADDRESS is "$VAULT_ADDRESS
mkdir .vault_howardeiner
aws s3 cp s3://zipster-aws-on-demand-vault/root_token .vault_howardeiner/root_token
export VAULT_TOKEN=$(<.vault_howardeiner/root_token)
echo "VAULT_TOKEN is "$VAULT_TOKEN
vault login -address=$VAULT_ADDRESS $VAULT_TOKEN > /dev/null

export SPARK_DNS_NAME=$(echo `cat ../../iac/terraform/awsqa_swarm/.spark_swarm_manager_dns`)
vault kv put -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK/ address=$SPARK_DNS_NAME > /dev/null
echo "SPARK_DNS_NAME is "$SPARK_DNS_NAME

rm -rf .vault_howardeiner
rm -rf /tmp/swarmprom.tar
