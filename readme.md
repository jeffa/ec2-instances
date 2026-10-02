EC2 Instances
=================
Terraform/Ansible starter kit for AWS

For a detailed walkthrough, code review, limitations, and recommendations for a Docker/EC2 split, see [PROJECT_REVIEW.md](PROJECT_REVIEW.md).

For the step-by-step WordPress Docker deployment guide, see [WORDPRESS_DOCKER_GUIDE.md](WORDPRESS_DOCKER_GUIDE.md).

For a disposable Laminas/PHP/MariaDB Docker deployment guide, see [LAMINAS_DOCKER_GUIDE.md](LAMINAS_DOCKER_GUIDE.md).

For the Laminas environment planning checklist, see [LAMINAS_ENVIRONMENT_QUESTIONNAIRE.md](LAMINAS_ENVIRONMENT_QUESTIONNAIRE.md).

Description
-----------
Launch ssh ready EC2 instances via Terrform and provision them with Ansible (installs Docker and nginx).

The practical goal is software compatibility testing: try an application across several Linux distributions, continue on a distribution where it installs and runs successfully, and destroy the temporary AWS instances when finished to avoid unnecessary charges.

Synopsis
--------
This is my starter kit for launching any number of Linux flavors for the purpose of setting up demos and trying out new packages.

* After running Terraform you should be able to immediately ssh into the instance(s) created. TF will "slurp" the contents of your SSH public key file and add them as authorized keys on the EC2 instance. TF will also perform a key scan on the newly obtained EC2 instance's IP address and add it as a known host on your local machine.

* After running Ansible you should be able to use Docker and access the web server running on port 80. Terraform generates a complete `ansible-hosts` inventory from the selected instances. Docker and nginx are separate playbooks, so either can be run independently.

* The default instance type is the free `t2.micro` but I recommend to always be in the habit of immediately destroying the instance(s) rather than leaving them running unattended.

Currently supports the following:
  * AWS Linux
  * Debian
  * Red Hat
  * Suse
  * Ubuntu

Dependencies
--------
* generate credentials for your AWS account
* create security groups for SSH and HTTP access
* create a public key for SSH access
* uses the Terraform-generated `ansible-hosts` file for Ansible inventory
* export vars:

```
export TF_VAR_aws_credentials=$HOME/.aws/credentials
export TF_VAR_id_rsa_path=$HOME/.ssh/id_rsa.pub
export TF_VAR_ssh_security_group=sg-*****************
export TF_VAR_http_security_group=sg-*****************
```

Terraform Plan Examples
-----------------------
```
# defaults to all (one of each server type)
terraform plan

# specify one or more servers
terraform plan -var 'servers=["ubuntu"]'
terraform plan -var 'servers=["red_hat","debian"]'
```

Runbook Example 
---------------
```
terraform plan -out run.me
terraform apply run.me
ansible all -i ansible-hosts -m ping
ansible-playbook -i ansible-hosts ansible/docker.yaml
ansible-playbook -i ansible-hosts ansible/nginx.yaml
terraform show | grep '_ssh =' | cut -d= -f2 | xargs -n1 curl -I
# terraform destroy -auto-approve
```

Known Issues
------------
* The Suse package installer zypper is failing to install nginx.
* Terraform waits for SSH readiness with a retry loop; inventory is generated as one complete file
