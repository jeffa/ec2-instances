EC2 Instances
=================
Terraform/Ansible starter kit for AWS

Description
-----------
Launch EC2 instances and install nginx on them.

Synopsis
--------
This is my starter kit for launching any number of Linux flavors for the purpose of setting up demos and trying out new packages.

* After running Terraform you should be able to immediately ssh into the instance(s) created. TF will "slurp" the contents of your SSH public key file and add them as authorized keys on the EC2 instance. TF will also perform a key scan on the newly obtained EC2 instance's IP address and add it as a known host on your local machine.

* After running Ansible you should be able to access the web server running on port 80. TF will first add the newly created EC2 instance's metadata as an Ansible inventory item to the inventory file (and subsequently remove it on destroy). Ansible will attempt to install nginx and ensure the necessary config files exist along with a sample home page.

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
* create a public key for SSH access
* create security groups for SSH and HTTP access
* uses `/etc/ansible/hosts` for Ansible inventory:
```
sudo mkdir /etc/ansible
sudo touch /etc/ansible/hosts
sudo chown -R $USER /etc/ansible/
```
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
ansible-playbook ansible/nginx.yaml
terraform show | grep '_ssh =' | cut -d= -f2 | xargs -n1 curl -I
terraform destroy -auto-approve
```

Known Issues
------------
* The Suse package installer zypper is failing to install nginx.
* Copious overusage of `sleep` to reduce chances of race conditions 
