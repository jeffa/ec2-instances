# WordPress / Kabler School for Dogs

This directory is a documentation boundary for the WordPress deployment solution.
The existing files have not been moved so current commands remain unchanged.

## Current entry points

- [WordPress Docker guide](WORDPRESS_DOCKER_GUIDE.md)
- [Canonical install helper](install.sh)
- [Legacy compatibility wrapper](../../install-wp.sh)
- [Shared EC2 laboratory](../../readme.md)

## Running the helper

Create the ignored environment file from the example and set a new development
password:

```bash
cp projects/wordpress/wordpress.env.example projects/wordpress/wordpress.env
${EDITOR:-vi} projects/wordpress/wordpress.env
./projects/wordpress/install.sh
```

The helper also accepts `WORDPRESS_ENV_FILE=/path/to/file` when a different secret
file is preferred. The password is no longer stored in the script. Because the old
credential existed in the old local script, it should not be reused.

## Local deployment wrapper

After Terraform and the Ansible Docker playbook have prepared an Ubuntu instance,
the local wrapper can copy the helper and environment file, verify Docker, and start
the deployment remotely:

```bash
cp projects/wordpress/wordpress.env.example projects/wordpress/wordpress.env
${EDITOR:-vi} projects/wordpress/wordpress.env

export EC2_HOST=<EC2-public-IP-or-DNS>
export EC2_USER=ubuntu
bin/wordpress/deploy.sh
```

The wrapper does not run Terraform, install Docker, destroy resources, or remove
existing containers. It expects Docker to have already been provisioned and stops if
Docker is unavailable for the SSH user.
