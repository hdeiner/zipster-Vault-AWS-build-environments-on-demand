#!/usr/bin/env bash

figlet -w 200 -f standard "Test in AWSQA-LAMBDA Environment"

export ENVIRONMENT=AWSQA-LAMBDA

export VAULT_ADDRESS="http://"$(<../../iac/terraform/vault/.vault_dns)":8200"
mkdir .vault_howardeiner
aws s3 cp s3://zipster-aws-on-demand-vault/root_token .vault_howardeiner/root_token
export VAULT_TOKEN=$(<.vault_howardeiner/root_token)
vault login -address=$VAULT_ADDRESS $VAULT_TOKEN > /dev/null

export ZIPSTER_URL=`vault kv get -address=$VAULT_ADDRESS ENVIRONMENTS/$ENVIRONMENT/ZIPSTER_URL | grep -E '^address[ ]*.' | awk '{print $2}'`

TEST_COMMAND="curl $ZIPSTER_URL -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -H 'x-api-key: *****************************' -d '{\"zipcode\":\"07440\",\"radius\":\"2.0\"}'"
echo $TEST_COMMAND
eval $TEST_COMMAND
echo ""

rm -rf .vault_howardeiner
