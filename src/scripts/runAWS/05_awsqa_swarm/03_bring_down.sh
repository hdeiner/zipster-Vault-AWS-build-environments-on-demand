#!/usr/bin/env bash

figlet -w 200 -f standard "Bring Down AWS-QA-SWARM Environment"
export ENVIRONMENT=AWS-QA-SWARM

figlet -w 160 -f small "Remove ENVIRONMENT from Vault"
export VAULT_ADDRESS="http://"$(<../../iac/terraform/vault/.vault_dns)":8200"
mkdir .vault_howardeiner
aws s3 cp s3://zipster-aws-on-demand-vault/root_token .vault_howardeiner/root_token
export VAULT_TOKEN=$(<.vault_howardeiner/root_token)
vault login -address=$VAULT_ADDRESS $VAULT_TOKEN > /dev/null

for path in $(vault kv list -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/ | tail -n+3);
  do
    vault kv delete -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/SPARK_SWARM_WORKER/${path};
  done

for path in $(vault kv list -address=$VAULT_ADDRESS ENVIRONMENTS/AWS-QA-SWARM/ | tail -n+3);
  do
    vault kv delete -address=$VAULT_ADDRESS ENVIRONMENTS/AWS-QA-SWARM/${path};
  done

rm -rf .vault_howardeiner/root_token

figlet -w 160 -f small "UnTerraform AWS-QA-SWARM"
cd ../../iac/terraform/awsqa_swarm
terraform destroy -var environment=AWS-QA-SWARM -auto-approve
rm -rf .environment .mysql_dns .spark_dns .spark_elb_dns .spark_swarm_manager_dns
cd -



