EC2 Instances
=================
Terraform/Ansible starter kit for AWS

Description
-----------
Launch EC2 instances and install nginx on them.

Synopsis
--------
This is my starter kit for launching any number of Linux flavors for the purpose of setting up demos and trying out new packages.

Currently supports the following:
  * AWS Linux
  * Debian
  * Red Hat
  * Suse
  * Ubuntu

ENV Vars
--------
```
export TF_VAR_aws_credentials=$HOME/.aws/credentials
export TF_VAR_id_rsa_path=$HOME/.ssh/id_rsa.pub
```

Terraform Plan Examples
-----------------------
```
# defaults to all one of each server type
terraform plan

# specify one or more
terraform plan -var 'server=["ubuntu"]'
terraform plan -var 'server=["red_hat","debian"]'
```

Runbook Example 
---------------
```
terraform plan -out run.me
terraform apply run.me
ansible-playbook ansible/ungrouped.yaml
terraform show | grep '_ssh =' | cut -d= -f2 | xargs -n1 curl
```

Known Issues
------------
The Suse package installer zypper is failing to install nginx.
