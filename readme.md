EC2 Instances
=================
Terraform/Ansible starter kit for AWS

For a detailed walkthrough, code review, limitations, and recommendations for a Docker/EC2 split, see [PROJECT_REVIEW.md](PROJECT_REVIEW.md).

For the step-by-step WordPress Docker deployment guide, see [WORDPRESS_DOCKER_GUIDE.md](WORDPRESS_DOCKER_GUIDE.md).

For a disposable Laminas/PHP/MariaDB Docker deployment guide, see [LAMINAS_DOCKER_GUIDE.md](LAMINAS_DOCKER_GUIDE.md).

For the Laminas environment planning checklist, see [LAMINAS_ENVIRONMENT_QUESTIONNAIRE.md](LAMINAS_ENVIRONMENT_QUESTIONNAIRE.md).

For Laminas database credential and local configuration guidance, see [LAMINAS_SECRET_CONFIGURATION_GUIDE.md](LAMINAS_SECRET_CONFIGURATION_GUIDE.md).

For AMI discovery strategies and image lifecycle guidance, see [AMI_DISCOVERY_GUIDE.md](AMI_DISCOVERY_GUIDE.md).

Description
-----------
Launch SSH-ready EC2 instances through Terraform and provision them with Ansible. The configuration uses one data-driven server matrix for the supported Linux flavors, generates a temporary Ansible inventory, and waits dynamically for SSH readiness.

The practical goal is software compatibility testing: try an application across several Linux distributions, continue on a distribution where it installs and runs successfully, and destroy the temporary AWS instances when finished to avoid unnecessary charges.

Synopsis
--------
This is my starter kit for launching any number of Linux flavors for the purpose of setting up demos and trying out new packages.

* After running Terraform you should be able to immediately ssh into the instance(s) created. Terraform injects the contents of your SSH public key file as authorized keys and polls port 22 until each selected host is reachable. The generated Ansible inventory accepts new host keys for this disposable lab without adding them to your global `known_hosts` file.

* After running Ansible you should be able to use Docker and access the web server running on port 80. Terraform generates a complete `ansible-hosts` inventory from the selected instances. Docker and nginx are separate playbooks, and each can be limited to compatible hosts.

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
* uses Docker on Ubuntu, Debian, and SUSE through distribution-specific package tasks
* treats Red Hat Docker installation as an experimental compatibility case; modern Red Hat images do not provide Docker Engine as a default `docker` package
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
terraform plan -out=run.me

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
ansible-playbook -i ansible-hosts ansible/docker.yaml --limit ubuntu
ansible-playbook -i ansible-hosts ansible/nginx.yaml --limit suse
terraform show | grep '_ssh =' | cut -d= -f2 | xargs -n1 curl -I
# terraform destroy -auto-approve
```

Run Docker and nginx against the distributions that support the capability being tested. The `--limit` examples above prevent one unsupported combination from blocking unrelated tests.

Known Issues
------------
* AMI IDs are still selected from the server matrix and should be reviewed as images age. See [AMI_DISCOVERY_GUIDE.md](AMI_DISCOVERY_GUIDE.md).
* Red Hat images generally require either Podman/container-tools or Docker’s official Docker CE repository; the default `docker` package task is not expected to work on modern RHEL images.
* nginx configuration paths vary by distribution. The playbook uses `sites-enabled` on Debian-family hosts and `conf.d/default.conf` on SUSE.
* Destroy the Terraform environment after testing to avoid ongoing AWS charges.
