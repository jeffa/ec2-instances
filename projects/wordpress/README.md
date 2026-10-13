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
Docker is unavailable for the SSH user. It also transfers the theme-asset helper so
that later asset deployments can reuse the existing remote tool.

## Deploy theme assets

To transfer and install a theme asset ZIP into the running WordPress container, use
the local asset wrapper from the repository root:

```bash
export EC2_HOST=<EC2-public-IP-or-DNS>
export EC2_USER=ubuntu

bin/wordpress/deploy-assets.sh \
  /path/to/kabler-school-for-dogs-assets.zip
```

The ZIP should contain this directory structure:

```text
kabler-school-for-dogs/
└── assets/
    ├── css/
    ├── js/
    └── ...
```

The optional second argument changes the theme slug:

```bash
bin/wordpress/deploy-assets.sh /path/to/theme-assets.zip another-theme-slug
```

The wrapper transfers the ZIP and
`projects/wordpress/deploy-theme-assets.sh` to the EC2 instance, extracts the
archive in a temporary directory, copies the assets into the theme, and applies
`www-data:www-data` ownership. It does not rebuild or restart the WordPress
container.
