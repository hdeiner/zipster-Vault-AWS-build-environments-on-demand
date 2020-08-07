#!/usr/bin/env bash

figlet -w 170 -f standard "Bring Down AWS-QA Environment"

figlet -w 160 -f small "UnTerraform AWS-QA"
cd ../../iac/terraform/awsqa
terraform destroy -var environment=AWS-QA -auto-approve
rm -rf .environment .mysql_dns .spark_dns
cd -
