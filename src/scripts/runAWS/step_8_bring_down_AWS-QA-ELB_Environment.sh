#!/usr/bin/env bash

figlet -w 170 -f standard "Bring Down AWS-QA-ELB Environment"

figlet -w 160 -f small "UnTerraform AWS-QA-ELB"
cd ../../iac/terraform/awsqa_elb
terraform destroy -var environment=AWS-QA-ELB -auto-approve
rm -rf .environment .mysql_dns .spark_dns .spark_elb_dns
cd -
