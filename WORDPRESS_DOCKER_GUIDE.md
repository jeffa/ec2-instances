# WordPress on Docker: first deployment guide

This guide starts with an Ubuntu EC2 instance that has Docker installed and no other web server running. It walks through launching WordPress, connecting it to MySQL, and deploying a custom frontend as a WordPress theme.

The deliberately small first milestone is:

1. Create a Docker network.
2. Start MySQL.
3. Start WordPress.
4. Complete the browser-based setup.
5. Convert the frontend into a WordPress theme.
6. Copy and activate the theme.

Do not add Compose, custom images, reverse proxies, HTTPS, or automated deployment until this version works.

## Before starting

You need an Ubuntu EC2 instance with Docker installed, SSH access, and security-group rules allowing TCP 22 from your IP address and TCP 80 from the internet. Keep SSH restricted to your own address. The commands below use placeholder passwords. Replace them with temporary values and do not commit real passwords to Git.

## The architecture

```text
Browser
   |
   | EC2 public IP:80
   v
WordPress container (Apache + PHP)
   |
   | Docker network: wordpress-network
   v
MySQL container
```

## What does `--network some-network` mean?

`some-network` in the official documentation is only an example name. Create your own user-defined network:

```bash
docker network create wordpress-network
```

Both containers will join that network. Docker then provides name-based discovery, so WordPress can contact the database using the container name `wp-db` instead of a changing container IP address. See Docker's [user-defined bridge network documentation](https://docs.docker.com/engine/network/drivers/bridge/).

The internal connection will be:

```text
WordPress container → wp-db:3306 → MySQL container
```

## Start MySQL

Create persistent volumes:

```bash
docker volume create wordpress-db
docker volume create wordpress-files
```

Start MySQL:

```bash
docker run -d \
  --name wp-db \
  --network wordpress-network \
  --restart unless-stopped \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD='change-this-password' \
  -e MYSQL_RANDOM_ROOT_PASSWORD=1 \
  -v wordpress-db:/var/lib/mysql \
  mysql:8.0
```

The MySQL variables mean:

| Variable | Meaning |
| --- | --- |
| `MYSQL_DATABASE` | Database WordPress will use. |
| `MYSQL_USER` | Non-root database user. |
| `MYSQL_PASSWORD` | Password for that user. |
| `MYSQL_RANDOM_ROOT_PASSWORD` | Generates a random root password. |

The `wordpress-db` volume keeps database files outside the container lifecycle.

Check the container:

```bash
docker ps
docker logs wp-db
```

## Start WordPress

```bash
docker run -d \
  --name wordpress \
  --network wordpress-network \
  --restart unless-stopped \
  -p 80:80 \
  -e WORDPRESS_DB_HOST=wp-db:3306 \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD='change-this-password' \
  -e WORDPRESS_DB_NAME=wordpress \
  -v wordpress-files:/var/www/html \
  wordpress:apache
```

The `WORDPRESS_DB_*` variables tell WordPress how to connect to MySQL:

| Variable | Value here | Meaning |
| --- | --- | --- |
| `WORDPRESS_DB_HOST` | `wp-db:3306` | MySQL container name and port. |
| `WORDPRESS_DB_USER` | `wordpress` | Must match `MYSQL_USER`. |
| `WORDPRESS_DB_PASSWORD` | Same temporary password | Must match `MYSQL_PASSWORD`. |
| `WORDPRESS_DB_NAME` | `wordpress` | Must match `MYSQL_DATABASE`. |

The official image documents this configuration, persistent volumes, Apache/FPM variants, and additional settings at the [official WordPress Docker image page](https://hub.docker.com/_/wordpress/).

Visit:

```text
http://YOUR_EC2_PUBLIC_IP
```

Complete the normal WordPress installation form and create a test administrator account.

If the page does not load, inspect the containers and listeners:

```bash
docker ps
docker logs wordpress
docker logs wp-db
sudo ss -ltnp | grep ':80'
```

Port 80 is intentional because this test instance is expected to run Docker only. If another service is already listening on port 80, stop or remove that service before starting the WordPress container.

## Turn the frontend into a WordPress theme

If the frontend is conventional HTML/CSS/JavaScript, it should usually become a WordPress theme rather than being copied directly over the WordPress installation.

A simple classic theme might look like this:

```text
my-theme/
├── style.css
├── index.php
├── functions.php
├── header.php
├── footer.php
├── page.php
├── single.php
└── assets/
    ├── css/
    ├── js/
    └── images/
```

The usual mapping is:

| Existing frontend | WordPress equivalent |
| --- | --- |
| Shared header | `header.php` or a block template part |
| Shared footer | `footer.php` or a block template part |
| Individual pages | WordPress Pages and page templates |
| Blog/article layout | `single.php` or a block template |
| Site-wide CSS | `style.css` and enqueued stylesheets |
| JavaScript/CSS dependencies | Enqueued through `functions.php` |
| Content images | WordPress Media Library |
| Design-specific images | Theme `assets/images/` |

WordPress describes themes as the presentation layer and recommends keeping site-critical functionality in plugins. See [What Is a Theme?](https://developer.wordpress.org/themes/getting-started/what-is-a-theme/). For classic themes, `style.css` and `index.php` are the essential starting files; see [Required Theme Files](https://developer.wordpress.org/themes/releasing-your-theme/required-theme-files/).

Do not copy the entire static site over `/var/www/html`. Convert its layout into a theme so WordPress can provide pages, menus, featured images, media management, and CMS behavior.

## Copy and activate the theme

From your development computer:

```bash
scp -r my-theme ubuntu@YOUR_EC2_PUBLIC_IP:~/my-theme
```

On the EC2 host:

```bash
docker cp ~/my-theme wordpress:/var/www/html/wp-content/themes/
docker exec wordpress \
  chown -R www-data:www-data /var/www/html/wp-content/themes/my-theme
```

Open `http://YOUR_EC2_PUBLIC_IP/wp-admin`, then select `Appearance → Themes → my-theme → Activate`.

Copying the theme is a good first deployment technique. A bind mount or custom image can provide a faster edit-and-refresh workflow later.

## Suggested first milestone

1. Start MySQL and WordPress.
2. Complete the WordPress setup.
3. Log into `/wp-admin`.
4. Create two or three test Pages.
5. Upload a few test images.
6. Create the smallest possible theme.
7. Make the homepage render one WordPress Page.
8. Add the shared header and footer.
9. Add the real frontend CSS and JavaScript.
10. Test against the client's WordPress.com staging site.

This separates infrastructure problems from frontend conversion problems. First prove WordPress works. Then prove the theme works. Then add the client's content and integration details.

## WordPress.com versus self-hosted WordPress

The Docker installation is useful for practicing themes, pages, media, plugins, REST API usage, and WordPress administration. It will not perfectly reproduce WordPress.com's managed platform, which may differ in hosting features, available plugins, authentication, caching, permissions, and API behavior.

If the frontend is actually a separate React, Vue, Next.js, or other application, WordPress may remain the content backend rather than the place where the frontend theme is installed. In that case, the application should consume the WordPress REST API. See WordPress.com's [REST API documentation](https://developer.wordpress.com/docs/api/) and [REST API URLs by site type](https://developer.wordpress.com/docs/rest-api-urls-by-site-type/).

Use this Docker installation for fast disposable testing, then use a WordPress.com staging site for final integration. WordPress.com documents staging and developer tools [here](https://developer.wordpress.com/docs/developer-tools/). Do not use the client's production site as the first integration target.

## Cleanup

Stop the containers but preserve data:

```bash
docker stop wordpress wp-db
```

Remove the containers but preserve volumes:

```bash
docker rm wordpress wp-db
```

If the lab is completely disposable and you want to remove its data too:

```bash
docker rm -f wordpress wp-db
docker volume rm wordpress-files wordpress-db
docker network rm wordpress-network
```

The final commands are irreversible for this lab's data. Export anything you want to keep first. When the EC2 test is complete, destroy the Terraform-managed instance so AWS does not continue charging for it.

## Troubleshooting commands

```bash
docker ps
docker ps -a
docker logs -f wordpress
docker logs -f wp-db
docker network inspect wordpress-network
docker exec -it wordpress bash
```

## The simple mental model

```text
Browser → EC2:80 → WordPress container → wp-db:3306 → MySQL container
```

The Docker network handles the container-to-container connection. The `WORDPRESS_DB_*` variables tell WordPress how to use it. The named volumes preserve WordPress files and MySQL data. Your theme is the frontend layer loaded from `wp-content/themes`.

Once this works, the next improvement should be a `compose.yaml` file that records these containers, variables, volumes, and network. Until then, the explicit `docker run` commands make every moving part visible.
