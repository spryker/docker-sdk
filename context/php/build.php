<?php

header('Content-Type: application/json');

echo json_encode([
    'self' => 'application',
    'build' => getenv('SPRYKER_BUILD_HASH'),
    'stamp' => getenv('SPRYKER_BUILD_STAMP'),
]);
