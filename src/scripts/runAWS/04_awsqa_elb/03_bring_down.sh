#!/usr/bin/env bash

figlet -w 170 -f standard "Bring Down AWS-QA-ELB Environment"
export ENVIRONMENT=AWS-QA-ELB

figlet -w 160 -f small "Remove ENVIRONMENT from Vault"
export VAULT_ADDRESS="http://"$(<../../iac/terraform/vault/.vault_dns)":8200"
mkdir .vault_howardeiner
aws s3 cp s3://zipster-aws-on-demand-vault/root_token .vault_howardeiner/root_token
export VAULT_TOKEN=$(<.vault_howardeiner/root_token)
vault login -address=$VAULT_ADDRESS $VAULT_TOKEN > /dev/null

for path in $(vault kv list -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/ | tail -n+3);
  do
    vault kv delete -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/${path};
  done

figlet -w 160 -f small "UnTerraform AWS-QA-ELB"
cd ../../iac/terraform/awsqa_elb
terraform destroy -var environment=AWS-QA-ELB -auto-approve
rm -rf .environment .mysql_dns .spark_dns .spark_elb_dns
cd -
