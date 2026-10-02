<?php

return [
    'db' => [
        'hostname' => getenv('DB_HOST') ?: 'db',
        'database' => getenv('DB_NAME') ?: 'horsesns_safari',
        'username' => getenv('DB_USER') ?: 'horsesns_safari',
        'password' => getenv('DB_PASSWORD') ?: '',
    ],
];
