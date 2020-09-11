### Building in Docker Containers, testing locally, and building AWS Environments.
<ul>
<li>Single AWS EC2 instances for MySQL and SPARK</li>
<li>AWS EC2 instance for MySQL, multiple AWS EC2 instances for SPARK, AWS ELB for load balancing</li>
<li>AWS EC2 instance for MySQL, AWS EC2 instance for Docker Swarm Manager for load balancing, multiple AWS EC2 instances for Docker Swarm Workers</li>
<li>AWS EC2 instance for MySQL, AWS Lambda for care free load balancing</li>
</ul>

##### Concept
Why do we use Docker Containers, anyway?  We want to be able to create environments, anything from simple short lived and test isolated environments and right through to production, using the same easy to follow techniques that reduce risk that deployments will go bad.  We reduce this risk by making deployments (even deployment environments) an everyday occurance, and testing frequently.

This project does all of that, and demonstrates a reference solution that includes secrets management using Vault in the process, so we can elimate the tyranny of decentralized environment configuration, and make system secrets something that systems ask for, rather than being pushed onto an environments surface. 

<ul>
<li>Docker containers.  Lots of them.  
<li>Docker Swarm orchestration and load balancing for demonstration and non-functional testing against.
<li>Prometheus, Grafana, cAdvisor, Node Exporter, Alert Manager, and Unsee (for environment monitoring and alerting)</li>
<li>Portainer (for container management and trouble shooting)</li>
<li>Java (for our code)
<li>Spark (for running a small REST server)
<li>MySQL (for persistence of a zipcode database)
<li>FlyWay (to version control the database)
<li>Vault is a vital component of this project.  We will use it for holding together environments, the endpoints in those environments,and the secrets needed for those environments.
</ul>

Here's a sample of what zipster does.  It searches for post offices within a given radius of a given zipcode.
![_curl-results-sample](assets/_curl-results-sample.png)

---
##### Explanation of the scripts to run.  
The scripts which comprise this project are grouped as follows.
<ol>
<li>creating the Docker Images we need for our Vault, MySQL, and Spark servers
<li>running the images quickly and locally, such as for when we are developing and testing our code (tests are not included in this project for brevity)
<li>running the images in AWS for three variants.  Both start with Vault being run and available for everyone.
<ul>
<li>bringing up an "AWS-QA" environment.  The name is just to distinguish it from other environments and to hint at the capabilities. 
<li>bringing up and "AWS-QA-ELB" environment.  Again, this name implies how one can put together a clustered environment.  Of course, using terraform, adding or removing additional EC2 instances from this are quite easy. 
<li>bringing up and "AWS-QA-ELB" environment.  Again, this name implies how one can put together a clustered environment.  Of course, using terraform, adding or removing additional EC2 instances from this are quite easy. 
</ul>
</ol>
Now, let's go into depth for each script.

---
##### createImages  
![createImages_step_1_create_vault_image_01](assets/createImages_step_1_create_vault_image_01.png)\
![createImages_step_1_create_vault_image_02](assets/createImages_step_1_create_vault_image_02.png)\
<BR />
![createImages_step_2_create_mysql_image_01](assets/createImages_step_2_create_mysql_image_01.png)\
![createImages_step_2_create_mysql_image_02](assets/createImages_step_2_create_mysql_image_01.png)\
<BR />
![createImages_step_3_create_spark_image_01](assets/createImages_step_3_create_spark_image_01.png)\
...\
![createImages_step_3_create_spark_image_02](assets/createImages_step_3_create_spark_image_02.png)\
---
##### run_Locally 
![runLocally_step_1_bring_up_01](assets/runLocally_step_1_bring_up_01.png)\
...\
![runLocally_step_1_bring_up_02](assets/runLocally_step_1_bring_up_02.png)\
<BR />
![runLocally_step_2_test_01](assets/runLocally_step_2_test_01.png)\
<BR />
![runLocally_step_3_bring_down_01](assets/runLocally_step_3_bring_down_01.png)\
---
##### runAWS 01_init 
![runAWS_01_init_01_terraform_init_01](assets/runAWS_01_init_01_terraform_init_01.png)\
...\
![runAWS_01_init_01_terraform_init_02](assets/runAWS_01_init_01_terraform_init_02.png)\
---
##### runAWS 02_vault 
![runAWS_02_vault_01_bring_up_01](assets/runAWS_02_vault_01_bring_up_01.png)\
...\
![runAWS_02_vault_01_bring_up_02](assets/runAWS_02_vault_01_bring_up_02.png)\
<BR />\
![runAWS_02_vault_01_bring_up_03](assets/runAWS_02_vault_01_bring_up_03.png)\
![runAWS_02_vault_01_bring_up_04](assets/runAWS_02_vault_01_bring_up_04.png)\
![runAWS_02_vault_01_bring_up_05](assets/runAWS_02_vault_01_bring_up_05.png)\
![runAWS_02_vault_01_bring_up_06](assets/runAWS_02_vault_01_bring_up_06.png)\
[we will bring down Vault at the very end, when everyone is done using it]
---
##### runAWS 03_awsqa  - one ec2 instance for MYSQL and one ec2 instance for Spark Zipster
<BR />\
Bring Up\
![runAWS_03_awsqa_01_bring_up_01](assets/runAWS_03_awsqa_01_bring_up_01.png)\
...\
![runAWS_03_awsqa_01_bring_up_02](assets/runAWS_03_awsqa_01_bring_up_02.png)\
<BR />\
Bring Up - Effect in AWS\
![runAWS_03_awsqa_01_bring_up_03](assets/runAWS_03_awsqa_01_bring_up_03.png)\
<BR />\
Bring Up - Effect in Vault\
![runAWS_03_awsqa_01_bring_up_04](assets/runAWS_03_awsqa_01_bring_up_04.png)\
![runAWS_03_awsqa_01_bring_up_05](assets/runAWS_03_awsqa_01_bring_up_05.png)\
![runAWS_03_awsqa_01_bring_up_06](assets/runAWS_03_awsqa_01_bring_up_06.png)\
![runAWS_03_awsqa_01_bring_up_07](assets/runAWS_03_awsqa_01_bring_up_07.png)\
![runAWS_03_awsqa_01_bring_up_08](assets/runAWS_03_awsqa_01_bring_up_08.png)\
<BR />\
Test\
![runAWS_03_awsqa_02_test_01](assets/runAWS_03_awsqa_02_test_01.png)\
<BR />\
Bring Down\
![runAWS_03_awsqa_03_bring_down_01](assets/runAWS_03_awsqa_03_bring_down_01.png)\
Bring Down - Effect in AWS\
![runAWS_03_awsqa_03_bring_down_02](assets/runAWS_03_awsqa_03_bring_down_02.png)\
<BR />\
Bring Down - Effect in Vault\
![runAWS_03_awsqa_03_bring_down_03](assets/runAWS_03_awsqa_03_bring_down_03.png)\
![runAWS_03_awsqa_03_bring_down_04](assets/runAWS_03_awsqa_03_bring_down_04.png)\
![runAWS_03_awsqa_03_bring_down_05](assets/runAWS_03_awsqa_03_bring_down_05.png)\
---
##### runAWS 04_awsqa_elb  - one ec2 instance for MYSQL, two ec2 instancex for Spark Zipster, one AWS ELB
<BR />\
Bring Up\
![runAWS_04_awsqa_elb_01_bring_up_01](assets/runAWS_04_awsqa_elb_01_bring_up_01.png)\
...\
![runAWS_04_awsqa_elb_01_bring_up_02](assets/runAWS_04_awsqa_elb_01_bring_up_02.png)\
<BR />\
Bring Up - Effect in AWS\
![runAWS_04_awsqa_elb_01_bring_up_03](assets/runAWS_04_awsqa_elb_01_bring_up_03.png)\
![runAWS_04_awsqa_elb_01_bring_up_04](assets/runAWS_04_awsqa_elb_01_bring_up_04.png)\
<BR />\
Bring Up - Effect in Vault\
![runAWS_04_awsqa_elb_01_bring_up_05](assets/runAWS_04_awsqa_elb_01_bring_up_05.png)\
![runAWS_04_awsqa_elb_01_bring_up_06](assets/runAWS_04_awsqa_elb_01_bring_up_06.png)\
![runAWS_04_awsqa_elb_01_bring_up_07](assets/runAWS_04_awsqa_elb_01_bring_up_07.png)\
![runAWS_04_awsqa_elb_01_bring_up_08](assets/runAWS_04_awsqa_elb_01_bring_up_08.png)\
![runAWS_04_awsqa_elb_01_bring_up_09](assets/runAWS_04_awsqa_elb_01_bring_up_09.png)\
![runAWS_04_awsqa_elb_01_bring_up_10](assets/runAWS_04_awsqa_elb_01_bring_up_10.png)\
<BR />\
Test\
![runAWS_04_awsqa_elb_02_test_01](assets/runAWS_04_awsqa_elb_02_test_01.png)\
<BR />\
Bring Down\
![runAWS_04_awsqa_elb_03_bring_down_01](assets/runAWS_04_awsqa_elb_03_bring_down_01.png)\
...\
![runAWS_04_awsqa_elb_03_bring_down_02](assets/runAWS_04_awsqa_elb_03_bring_down_02.png)\
Bring Down - Effect in AWS\
![runAWS_04_awsqa_elb_03_bring_down_03](assets/runAWS_04_awsqa_elb_03_bring_down_03.png)\
<BR />\
Bring Down - Effect in Vault\
![runAWS_04_awsqa_elb_03_bring_down_04](assets/runAWS_04_awsqa_elb_03_bring_down_04.png)\
![runAWS_04_awsqa_elb_03_bring_down_05](assets/runAWS_04_awsqa_elb_03_bring_down_05.png)\
![runAWS_04_awsqa_elb_03_bring_down_06](assets/runAWS_04_awsqa_elb_03_bring_down_06.png)\
![runAWS_04_awsqa_elb_03_bring_down_07](assets/runAWS_04_awsqa_elb_03_bring_down_07.png)\
---
##### runAWS 05_awsqa_swarm  - one ec2 instance for MYSQL, two ec2 instances for Swarm Workers, one ec2 instance for Swarm Manager (plus portainern and prometheus and grafana)
<BR />\
Bring Up\
![runAWS_05_awsqa_swarm_01_bring_up_01](assets/runAWS_05_awsqa_swarm_01_bring_up_01.png)\
...\
![runAWS_05_awsqa_swarm_01_bring_up_02](assets/runAWS_05_awsqa_swarm_01_bring_up_02.png)\
<BR />\
Bring Up - Effect in AWS\
![runAWS_05_awsqa_swarm_01_bring_up_03](assets/runAWS_05_awsqa_swarm_01_bring_up_03.png)\
<BR />\
Bring Up - Effect in Vault\
![runAWS_05_awsqa_swarm_01_bring_up_04](assets/runAWS_05_awsqa_swarm_01_bring_up_04.png)\
![runAWS_05_awsqa_swarm_01_bring_up_05](assets/runAWS_05_awsqa_swarm_01_bring_up_05.png)\
![runAWS_05_awsqa_swarm_01_bring_up_06](assets/runAWS_05_awsqa_swarm_01_bring_up_06.png)\
![runAWS_05_awsqa_swarm_01_bring_up_07](assets/runAWS_05_awsqa_swarm_01_bring_up_07.png)\
![runAWS_05_awsqa_swarm_01_bring_up_08](assets/runAWS_05_awsqa_swarm_01_bring_up_08.png)\
![runAWS_05_awsqa_swarm_01_bring_up_09](assets/runAWS_05_awsqa_swarm_01_bring_up_09.png)\
![runAWS_05_awsqa_swarm_01_bring_up_10](assets/runAWS_05_awsqa_swarm_01_bring_up_10.png)\
![runAWS_05_awsqa_swarm_01_bring_up_11](assets/runAWS_05_awsqa_swarm_01_bring_up_11.png)\
![runAWS_05_awsqa_swarm_01_bring_up_12](assets/runAWS_05_awsqa_swarm_01_bring_up_12.png)\
![runAWS_05_awsqa_swarm_01_bring_up_13](assets/runAWS_05_awsqa_swarm_01_bring_up_13.png)\
<BR />\
Test\
![runAWS_05_awsqa_swarm_02_test_01](assets/runAWS_05_awsqa_swarm_02_test_01.png)\
<BR />\
Test - Look at Manager Node\
![runAWS_05_awsqa_swarm_02_test_manager_node_01](assets/runAWS_05_awsqa_swarm_02_test_manager_node_01.png)\
<BR />\
Test - Look at Portainer\
![runAWS_05_awsqa_swarm_02_test_portainer_01](assets/runAWS_05_awsqa_swarm_02_test_portainer_01.png)\
![runAWS_05_awsqa_swarm_02_test_portainer_02](assets/runAWS_05_awsqa_swarm_02_test_portainer_02.png)\
![runAWS_05_awsqa_swarm_02_test_portainer_03](assets/runAWS_05_awsqa_swarm_02_test_portainer_03.png)\
![runAWS_05_awsqa_swarm_02_test_portainer_04](assets/runAWS_05_awsqa_swarm_02_test_portainer_04.png)\
![runAWS_05_awsqa_swarm_02_test_portainer_06](assets/runAWS_05_awsqa_swarm_02_test_portainer_05.png)\
![runAWS_05_awsqa_swarm_02_test_portainer_06](assets/runAWS_05_awsqa_swarm_02_test_portainer_06.png)\
![runAWS_05_awsqa_swarm_02_test_portainer_07](assets/runAWS_05_awsqa_swarm_02_test_portainer_07.png)\
<BR />\
Test - Look at Grafana\
![runAWS_05_awsqa_swarm_02_test_grafana_01](assets/runAWS_05_awsqa_swarm_02_test_grafana_01.png)\
![runAWS_05_awsqa_swarm_02_test_grafana_02](assets/runAWS_05_awsqa_swarm_02_test_grafana_02.png)\
![runAWS_05_awsqa_swarm_02_test_grafana_03](assets/runAWS_05_awsqa_swarm_02_test_grafana_03.png)\
![runAWS_05_awsqa_swarm_02_test_grafana_04](assets/runAWS_05_awsqa_swarm_02_test_grafana_04.png)\
<BR />\
Bring Down\
![runAWS_05_awsqa_swarm_03_bring_down_01](assets/runAWS_05_awsqa_swarm_03_bring_down_01.png)\
...\
![runAWS_05_awsqa_swarm_03_bring_down_02](assets/runAWS_05_awsqa_swarm_03_bring_down_02.png)\
Bring Down - Effect in AWS\
![runAWS_05_awsqa_swarm_03_bring_down_03](assets/runAWS_05_awsqa_swarm_03_bring_down_03.png)\
<BR />\
Bring Down - Effect in Vault\
![runAWS_05_awsqa_swarm_03_bring_down_04](assets/runAWS_05_awsqa_swarm_03_bring_down_04.png)\
![runAWS_05_awsqa_swarm_03_bring_down_05](assets/runAWS_05_awsqa_swarm_03_bring_down_05.png)\
![runAWS_05_awsqa_swarm_03_bring_down_06](assets/runAWS_05_awsqa_swarm_03_bring_down_06.png)\
![runAWS_05_awsqa_swarm_03_bring_down_07](assets/runAWS_05_awsqa_swarm_03_bring_down_07.png)\
![runAWS_05_awsqa_swarm_03_bring_down_08](assets/runAWS_05_awsqa_swarm_03_bring_down_08.png)\
![runAWS_05_awsqa_swarm_03_bring_down_09](assets/runAWS_05_awsqa_swarm_03_bring_down_09.png)\
![runAWS_05_awsqa_swarm_03_bring_down_10](assets/runAWS_05_awsqa_swarm_03_bring_down_10.png)\
![runAWS_05_awsqa_swarm_03_bring_down_11](assets/runAWS_05_awsqa_swarm_03_bring_down_11.png)\
##### runAWS 02_vault [bring down]
![runAWS_02_vault_03_bring_down_01](assets/runAWS_02_vault_03_bring_down_01.png)\
<BR />\
![runAWS_02_vault_03_bring_down_02](assets/runAWS_02_vault_03_bring_down_02.png)
