# Project Map

This repository contains a shared EC2 laboratory and two application deployment
solutions. The projects are documented separately here without moving their existing
files or changing their current commands.

## EC2 laboratory

The laboratory provisions disposable AWS instances and tests software compatibility
across Linux distributions.

| Area | Current location |
| --- | --- |
| Terraform root configuration | `main.tf`, `ec2_instances.tf`, `variables.tf`, `inventory.tf` |
| EC2 module | `modules/ec2_instance/` |
| Host provisioning | `ansible/` |
| General laboratory documentation | `PROJECT_REVIEW.md`, `AMI_DISCOVERY_GUIDE.md` |
| Generated inventory | `ansible-hosts` (local/generated; do not commit) |

The laboratory files are shared infrastructure. They should remain independent of the
WordPress and Laminas application payloads.

## WordPress / Kabler School for Dogs

The WordPress work is a disposable Docker deployment experiment.

| Area | Current location |
| --- | --- |
| Deployment guide | `WORDPRESS_DOCKER_GUIDE.md` |
| Existing helper entry point | `install-wp.sh` |
| Project notes | `projects/wordpress/` |

`install-wp.sh` remains in its current location for compatibility during this cleanup.
Before it is reused for a new environment, its credential handling must be reviewed.

## Laminas / Safari Run

The Laminas work is a PHP 8.1/Apache/MariaDB Docker deployment for disposable
development and integration testing.

| Area | Current location |
| --- | --- |
| Compose stack and Docker configuration | `laminas-dev/` |
| Local deployment scripts | `bin/laminas-dev/local/` |
| Remote deployment scripts | `bin/laminas-dev/remote/` |
| Ignored source and database payloads | `laminas-input/` |
| Project guides | `LAMINAS_*.md`, `laminas-dev/README.md` |
| Project notes | `projects/laminas-safari/` |

The Laminas scripts must continue to be run from the repository root. The current
paths are part of the deployment contract and should not be moved until compatibility
wrappers or updated path resolution have been tested.

## Cleanup rules for this branch

1. Documentation and navigation may be added without changing deployment paths.
2. Shared Terraform and Ansible remain at the repository root.
3. Application-specific files are not mixed into the shared infrastructure directories.
4. Ignored payloads and credentials remain outside Git-tracked application artifacts.
5. Any future file move must preserve the existing command through a wrapper until the
   replacement path has been tested.

## Possible future repository split

When the projects are ready to move, the likely split is:

```text
ec2-instances       Shared Terraform, Ansible, and Linux compatibility laboratory
wordpress-deploy    WordPress-specific deployment guide and helpers
laminas-safari      Laminas application stack and deployment workflow
```

Until then, this repository remains the source of truth for the working deployment
scripts.
