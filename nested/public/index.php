<?php

use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Add debug logging
file_put_contents(
    __DIR__.'/../storage/logs/debug.log',
    date('Y-m-d H:i:s') . ' - Request started - ' . $_SERVER['REQUEST_URI'] . PHP_EOL,
    FILE_APPEND
);

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    file_put_contents(
        __DIR__.'/../storage/logs/debug.log',
        date('Y-m-d H:i:s') . ' - Maintenance check' . PHP_EOL,
        FILE_APPEND
    );
    require $maintenance;
}

// Register the Composer autoloader...
try {
    require __DIR__.'/../vendor/autoload.php';
    file_put_contents(
        __DIR__.'/../storage/logs/debug.log',
        date('Y-m-d H:i:s') . ' - Autoloader loaded' . PHP_EOL,
        FILE_APPEND
    );
} catch (Exception $e) {
    file_put_contents(
        __DIR__.'/../storage/logs/debug.log',
        date('Y-m-d H:i:s') . ' - Autoloader error: ' . $e->getMessage() . PHP_EOL,
        FILE_APPEND
    );
}

// Bootstrap Laravel and handle the request...
try {
    $app = require_once __DIR__.'/../bootstrap/app.php';
    file_put_contents(
        __DIR__.'/../storage/logs/debug.log',
        date('Y-m-d H:i:s') . ' - App bootstrapped' . PHP_EOL,
        FILE_APPEND
    );
    $app->handleRequest(Request::capture());
} catch (Exception $e) {
    file_put_contents(
        __DIR__.'/../storage/logs/debug.log',
        date('Y-m-d H:i:s') . ' - Request handling error: ' . $e->getMessage() . PHP_EOL,
        FILE_APPEND
    );
    throw $e;
}
