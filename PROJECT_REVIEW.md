# EC2 Linux Variant Lab: project review and operating guide

This repository is a small disposable Linux laboratory. Terraform creates one or more EC2 instances, injects an SSH public key, and writes connection information into an Ansible inventory. Separate Ansible playbooks can install Docker and configure nginx with a sample page.

The deeper purpose is compatibility testing. Installing application X can be surprisingly different across Linux distributions even when Ansible is used. The lab makes it practical to try the application on several distributions, continue on the one where it works best, and destroy the temporary AWS instances immediately afterward so they do not create unnecessary cost.

That is a reasonable learning project and it solves a real problem: obtain several clean Linux machines quickly, with passwordless SSH, so that automation can start immediately. The main tradeoff is that the project uses Terraform as both an AWS resource manager and a local scripting tool. The latter part is where most of the fragility comes from.

## What the repository does

The flow is:

```text
Terraform configuration
        |
        | aws_instance + user_data
        v
EC2 instance with the local public key in authorized_keys
        |
        | Terraform-generated inventory file
        v
local Ansible inventory (`ansible-hosts` by default)
        |
        | ansible-playbook ansible/docker.yaml
        | ansible-playbook ansible/nginx.yaml
        v
nginx + sample web page on each host
```

The five selectable names are `aws_linux`, `debian`, `red_hat`, `suse`, and `ubuntu`. The root files select an AMI, default login name, instance name, and child module for each name. The modules then create nearly identical `aws_instance` resources.

The Ansible playbook targets `ungrouped`, so it acts on every host written as a host-level inventory entry. Its tasks create directories, install nginx through Ansible's generic `package` module, install the nginx configuration, render the page, and restart nginx.

## How to run the existing project

This is the safest documented runbook for the current layout. Run it from the repository root.

### Prerequisites

Install and configure:

- Terraform
- Ansible
- AWS CLI credentials with permission to create and destroy EC2 instances
- an SSH key pair; the public key path is passed to Terraform
- an AWS VPC/subnet context in which the referenced security groups are valid

The security groups supplied below must allow inbound TCP 22 from your IP address and TCP 80 from wherever you intend to test the web server. Keep SSH restricted to your own address; do not use a broad internet-wide rule for convenience.

The AMI IDs in `aws_linux.tf`, `debian.tf`, `red_hat.tf`, `suse.tf`, and `ubuntu.tf` are region-specific and should be treated as examples, not permanent identifiers. Confirm that each AMI exists in `TF_VAR_aws_region`, is still supported, and has the expected default user before launching.

### Configure input variables

The original project expects environment variables. Set them in the shell running Terraform:

```bash
export TF_VAR_aws_credentials="$HOME/.aws/credentials"
export TF_VAR_id_rsa_path="$HOME/.ssh/id_rsa.pub"
export TF_VAR_aws_region="us-east-1"
export TF_VAR_ssh_security_group="sg-xxxxxxxxxxxxxxxxx"
export TF_VAR_http_security_group="sg-yyyyyyyyyyyyyyyyy"
```

The AWS provider can also use the normal AWS CLI credential chain. In a modernization, prefer that approach over passing a credentials-file path as a Terraform variable.

Terraform now generates the inventory at the path in `ansible_inv_path`, which defaults to the project-local `ansible-hosts` file:

```bash
ansible all -i ansible-hosts -m ping
```

### Select distributions

The default is one instance of every distribution:

```bash
terraform plan
```

For a smaller, cheaper test:

```bash
terraform plan -var='servers=["ubuntu"]'
terraform plan -var='servers=["ubuntu","debian"]'
```

The values must match the names in `variables.tf`. `servers` is a list, but the root modules filter it and use `for_each`, so each supported name results in at most one instance.

### Initialize, plan, apply, and connect

Initialize the provider and local modules first:

```bash
terraform init
terraform validate
terraform plan -out=run.tfplan
terraform apply run.tfplan
```

The outputs provide a username and public IP for each selected distribution:

```bash
terraform output
```

The SSH command is conceptually:

```bash
ssh <username>@<public-ip>
```

The login names are normally `ec2-user` for Amazon Linux, `admin` for Debian in this project, `ec2-user` for Red Hat and SUSE, and `ubuntu` for Ubuntu. Verify these assumptions against the selected AMIs.

The instance user data appends the public key to the image user's `authorized_keys`. Terraform polls TCP port 22 with a bounded retry loop. The generated inventory uses `StrictHostKeyChecking=accept-new` for these disposable hosts, and Ansible then waits for a usable connection before gathering facts.

### Run Ansible

Once Terraform has completed and the hosts are reachable:

```bash
ansible all -i ansible-hosts -m ping

# Run either playbook or both, independently
ansible-playbook -i ansible-hosts ansible/docker.yaml
ansible-playbook -i ansible-hosts ansible/nginx.yaml
```

The repository's playbook uses `hosts: ungrouped`, so `ansible all -i ansible-hosts -m ping` is a useful first check but the playbook itself will use the ungrouped entries. After the playbook succeeds, request port 80 from each public IP, or use the output values to construct a URL:

```bash
curl -I http://<public-ip>/
```

The SUSE failure is a known project limitation. It is plausibly related to package-manager behavior, repository state, or the old SUSE image rather than to Terraform's instance creation. Since the goal here is review rather than repair, treat SUSE as an experimental target and validate the other distributions independently. Docker and nginx are intentionally separate playbooks, so a Docker-only experiment does not need to configure the web server.

### Destroy everything

When finished, release the instances and their hourly charges:

```bash
terraform destroy
```

The generated inventory is owned by Terraform and is removed when its Terraform resource is destroyed. It is ignored by Git and should not be edited manually.

## Important limitations in the checked-in code

These are worth knowing before investing more time in the current implementation:

1. **The active EC2 module is data-driven.** The supported images and login users are defined in one server matrix, and one reusable module creates the selected instances.

2. **Legacy duplicate modules were removed.** The old distribution-specific module directories and `.modules` files were not loaded by Terraform and have been removed to prevent future edits from targeting inactive code.

3. **Inventory is generated from Terraform data.** A single generated file avoids per-instance append/remove races, stale entries, and platform-specific `sed` cleanup.

4. **The inventory path is configurable.** `ansible_inv_path` controls the generated inventory location and defaults to the project-local `ansible-hosts` file.

5. **SSH host-key handling is appropriate only for the disposable lab.** The generated inventory uses `StrictHostKeyChecking=accept-new`, so new keys are accepted without polluting the user's global `known_hosts`. For anything important, use a trusted host-key process.

6. **Readiness uses bounded retries.** Terraform polls for SSH readiness, and Ansible uses `wait_for_connection` before gathering facts. Package repository readiness remains an operating-system-specific concern.

7. **The AMIs and provider configuration are old-style inputs.** AMI IDs age, differ by region and architecture, and may have changing default users. The AWS provider constraint is also pinned to the old 3.x major line and there is no committed dependency lock file.

8. **The networking boundary is outside this repository.** Security groups are passed in as IDs, so the project is not self-contained or reproducible for a new AWS account. That is fine for a personal lab, but it should be stated as a prerequisite.

9. **The page has external dependencies and project-specific URLs.** The generated HTML loads JavaScript and Bootstrap from CDNs and refers to `unlocalhost.com` and `jeffa.unlocalhost.com`. It is a demo page, not an isolated test fixture.

## What I would use instead

There are two different jobs hiding in the original requirement:

| Job | Better default | Why |
| --- | --- | --- |
| Try an application, package, nginx config, or Ansible role against several Linux userlands | Docker Compose or a small container test matrix | Fast startup, cheap, repeatable, no public IPs, no security groups, no AMI maintenance |
| Test a real VM, cloud-init, systemd, kernel behavior, EC2 networking, IAM, or an exact cloud image | Terraform, but with cloud-init and generated outputs | Those behaviors are not faithfully represented by ordinary containers |

Docker is not a replacement for every Linux server. Containers share the host kernel and usually do not model a complete init system, block devices, boot behavior, or cloud metadata. They are, however, an excellent replacement for the current “install nginx and try a package/configuration on multiple distributions” loop.

### Recommended practical split

Use Docker Compose for the daily loop when the application only needs userland/package compatibility:

```yaml
services:
  ubuntu:
    image: ubuntu:24.04
    command: ["sleep", "infinity"]
  debian:
    image: debian:12
    command: ["sleep", "infinity"]
  fedora:
    image: fedora:latest
    command: ["sleep", "infinity"]
```

Then either run commands with `docker compose exec`, or use Ansible's local/container connection. For Ansible learning, keep the playbook and replace the cloud inventory with a small static or generated inventory whose hostnames are the Compose service names. You do not need SSH keys or `ssh-keyscan` when Ansible connects through the container runtime.

Keep a separate Terraform stack for the cases where EC2 itself matters, or when the application needs a full VM. That stack can launch one selected AMI, use cloud-init to install the minimum bootstrap packages, and expose an output containing the instance address. Ansible can then consume that output through a generated inventory or a dynamic AWS inventory plugin. The two tools remain clearly separated: Terraform declares infrastructure; Ansible configures already-reachable machines. Destroy the test environment as soon as the compatibility decision is made.

## If this were rewritten in Terraform/Ansible

If EC2 remains the target, I would make these changes in order:

1. Replace the five root files and five child modules with one map describing each image: `name`, `ami`, `username`, and perhaps `ansible_group`.
2. Create one `aws_instance` with `for_each = var.server_matrix`, and pass the selected map values into it.
3. Move the public-key bootstrap into cloud-init/user data, with correct file ownership and permissions. Do not use a Terraform provisioner for routine machine initialization.
4. Output a structured map such as `{ ubuntu = { host = "...", user = "ubuntu" } }`.
5. Generate a temporary inventory from that output, or use an AWS inventory mechanism based on tags. Do not append and delete lines in a shared system file.
6. Put the nginx work into an Ansible role with handlers: install the package, copy the configuration, notify a handler, and let the handler restart/reload nginx only when the configuration changes.
7. Add distribution variables or OS-specific task files where package names, service names, paths, or repositories differ. A generic `package` task does not eliminate all distribution differences.
8. Pin and commit provider dependencies, format and validate in CI, and add a documented AMI update process.
9. Separate Ansible playbooks or roles by capability, such as Docker and nginx, and use `--limit` or inventory groups so an unsupported distribution/tool combination does not block unrelated tests. For example:

   ```bash
   ansible-playbook -i ansible-hosts ansible/docker.yaml --limit ubuntu
   ansible-playbook -i ansible-hosts ansible/nginx.yaml --limit suse
   ```

This preserves the educational value of the project while removing the most surprising mechanics. It also makes it possible to run Terraform and Ansible from a clean checkout without requiring a writable `/etc` directory.

## Bottom line

The project is a successful proof of concept for “bring up several SSH-ready EC2 machines and configure them.” It is not yet the simplest or most reliable tool for rapid prototyping. For the likely day-to-day work—trying packages, nginx, and Ansible tasks—start with containers and reserve AWS for tests that genuinely require a VM or cloud integration. If you continue with EC2, refactor around a single data-driven module, cloud-init, structured Terraform outputs, and generated/dynamic Ansible inventory.
