# WordPress / Kabler School for Dogs

This directory is a documentation boundary for the WordPress deployment solution.
The existing files have not been moved so current commands remain unchanged.

## Current entry points

- [WordPress Docker guide](../../WORDPRESS_DOCKER_GUIDE.md)
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
