docker cp provision-kabler.php wordpress:/tmp/provision-kabler.php

docker inspect \
  --format '{{range .Config.Env}}{{println .}}{{end}}' \
  wordpress > /tmp/wordpress-cli.env

docker run --rm -it \
  --env-file /tmp/wordpress-cli.env \
  --volumes-from wordpress \
  --network container:wordpress \
  -v "$PWD/provision-kabler.php:/tmp/provision-kabler.php:ro" \
  wordpress:cli \
  --allow-root \
  --path=/var/www/html \
  eval-file /tmp/provision-kabler.php

rm -f /tmp/wordpress-cli.env
