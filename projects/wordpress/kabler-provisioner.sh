docker cp provision-kabler.php wordpress:/tmp/provision-kabler.php

docker exec -it wordpress \
  wp --allow-root \
  --path=/var/www/html \
  eval-file /tmp/provision-kabler.php
