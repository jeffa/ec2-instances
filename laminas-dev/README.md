# Laminas development stack

This Compose project runs the supplied Laminas application with PHP 8.1/Apache and MariaDB 10.6.28. It is intended for disposable local development and integration testing, not production.

The application source and `.env` file are intentionally ignored by Git. The runtime configuration reads database credentials from the container environment, so `config/autoload/local.php` does not need to be included in the source tarball.

## Scripted EC2 workflow

The repository contains separate local and remote scripts under `bin/laminas-dev/`. Run the local scripts from the repository root after Docker has been provisioned on the EC2 instance:

The remote scripts automatically use either the Docker Compose v2 plugin (`docker compose`) or the standalone Compose command (`docker-compose`).

For the shorter workflow, run the local wrapper from the repository root:

```bash
export EC2_HOST=<EC2-public-IP-or-DNS>
export EC2_USER=ubuntu
bin/laminas-dev/local/04-deploy-wrapper.sh
```

Then connect to EC2, create/edit `.env`, and run the remote wrapper:

```bash
ssh "$EC2_USER@$EC2_HOST"
cd ~/laminas-dev
bash remote/99-deploy-wrapper.sh
nano .env
bash remote/99-deploy-wrapper.sh
```

The remote wrapper calls the existing numbered scripts without modifying them. It waits for MariaDB and Apache readiness, checks for the `tblSessions` table before skipping the import, retries the HTTP check, and records output in `~/laminas-dev/deploy.log`. Use `FORCE_DB_RESTORE=1 bash remote/99-deploy-wrapper.sh` only when intentionally reapplying the dump. If the database volume is deleted with `docker compose down -v`, the schema check automatically triggers a new import:

```bash
tail -f ~/laminas-dev/deploy.log
```

### Manual script-by-script workflow

```bash
export EC2_HOST=<EC2-public-IP-or-DNS>
export EC2_USER=ec2-user

bin/laminas-dev/local/01-package-stack.sh
bin/laminas-dev/local/02-copy-stack.sh
bin/laminas-dev/local/03-copy-payloads.sh
```

The local scripts copy only the deployment configuration and the two ignored payloads. They do not use Git on the EC2 instance.

Connect to the instance and run the remote scripts in order:

```bash
ssh "$EC2_USER@$EC2_HOST"
```

Run these commands on the EC2 instance. The archive must be extracted before the remote scripts are available:

```bash
mkdir -p ~/laminas-dev
tar -xzf ~/laminas-dev-stack.tar.gz -C ~/laminas-dev --strip-components=1

cd ~/laminas-dev
bash remote/02-create-env.sh
nano .env
bash remote/03-extract-app.sh
bash remote/04-build-image.sh
bash remote/05-start-database.sh
bash remote/06-restore-database.sh
bash remote/07-start-application.sh
bash remote/08-verify.sh
```

Because the archive extracts its contents directly into `~/laminas-dev`, the `remote/01-extract-stack.sh` helper is useful when the stack archive is copied into a different location or when the standard extraction needs to be repeated:

```bash
bash ~/laminas-dev/remote/01-extract-stack.sh
```

Do not run the database restore more than once against an already-populated volume unless the dump is intended to be re-applied. For a clean disposable rebuild, use `docker compose down -v` from `~/laminas-dev` first.

## Prepare the application

From this directory, extract the ignored source payload into `app/`:

```bash
rm -rf app
mkdir app
tar -xzf ../laminas-input/laminas-app.tar.gz -C app
```

The application root should be directly under `app/`, with `composer.json`, `composer.lock`, `config/`, `module/`, `public/`, and `bin/` visible there.

Create local credentials:

```bash
cp .env.example .env
chmod 600 .env
```

Edit `.env` and replace both temporary passwords. Keep these values private even though this environment is disposable.

## Build and start

```bash
docker compose build
docker compose up -d
docker compose ps
docker compose logs -f app
```

The application is available at <http://localhost/>. The Apache document root is `app/public`, not the application root.

## Restore the development database

The supplied dump includes its own `CREATE DATABASE` and `USE` statements. Start the database, load the dump as root, then start or restart the application:

```bash
set -a
. ./.env
set +a

docker compose up -d db
gzip -dc ../laminas-input/horsesns_safari-dev.sql.gz | \
  docker compose exec -T db mariadb -uroot -p"$DB_ROOT_PASSWORD"

docker compose up -d app
docker compose exec app php bin/clear-config-cache.php
```

If the import reports that tables already exist, the named volume already contains a database. For a clean rebuild, stop the stack and remove only this project’s volume:

```bash
docker compose down -v
docker compose up -d
```

## Verify the runtime

```bash
curl -I http://localhost/
docker compose logs --tail=100 app
docker compose exec app php -m
docker compose exec app composer check-platform-reqs
```

The last command should confirm the PHP extensions required by the locked dependency set. This development image intentionally installs Composer development dependencies because the application registers `Laminas\\DeveloperTools`, which is declared under `require-dev`. The image includes the application’s expected extensions, including `pdo_mysql`, `intl`, `mbstring`, `gd`, `soap`, XML/DOM, cURL, and ZIP.

`DEMO_MODE=1` is passed into the application and converted to the legacy PHP `DEMO_MODE` constant by the runtime-only configuration. The image also provides a compatibility symlink for the bundled PHPMailer code, whose current legacy `require` statements expect `/var/www/html/PHPMailer`. The long-term source fix is to replace those relative `require` paths with paths based on `__DIR__` or Composer autoloading.

The source archive stores the application’s `assets/` directory beside `public/`, while the Apache document root is `public/`. The development image therefore links `public/assets` to the existing root-level directory so URLs such as `/assets/css/site.css` remain available.

`APP_BASE_PATH=/` overrides the legacy `/safari2/` deployment prefix at runtime. Keep it set to `/` when the application is served from the domain root; use a value such as `/safari2` only when a reverse proxy intentionally serves the application beneath that subpath.

## Stop the stack

```bash
docker compose down
```

Use `docker compose down -v` only when the disposable database volume should also be deleted.
