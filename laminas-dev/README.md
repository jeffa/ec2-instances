# Laminas development stack

This Compose project runs the supplied Laminas application with PHP 8.1/Apache and MariaDB 10.6.28. It is intended for disposable local development and integration testing, not production.

The application source and `.env` file are intentionally ignored by Git. The runtime configuration reads database credentials from the container environment, so `config/autoload/local.php` does not need to be included in the source tarball.

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
gzip -dc ../laminas-input/horsensns_safari-dev.sql.gz | \
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
docker compose exec app composer check-platform-reqs --no-dev
```

The last command should confirm the PHP extensions required by the locked dependency set. The image includes the application’s expected extensions, including `pdo_mysql`, `intl`, `mbstring`, `gd`, `soap`, XML/DOM, cURL, and ZIP.

## Stop the stack

```bash
docker compose down
```

Use `docker compose down -v` only when the disposable database volume should also be deleted.
