#!/usr/bin/env bash

figlet -w 160 -f standard "Terraform Init"

figlet -w 160 -f small "Init Vault Server"
cd ../../iac/terraform/vault
terraform init
cd -

figlet -w 160 -f small "Init AWSQA"
cd ../../iac/terraform/awsqa
terraform init
cd -

figlet -w 160 -f small "Init AWSQA-ELB"
cd ../../iac/terraform/awsqa_elb
terraform init
cd -

figlet -w 160 -f small "Init AWSQA-SWARM"
cd ../../iac/terraform/awsqa_swarm
terraform init
cd -

figlet -w 160 -f small "Init AWSQA-LAMBDA"
cd ../../iac/terraform/awsqa_lambda
terraform init
cd -
