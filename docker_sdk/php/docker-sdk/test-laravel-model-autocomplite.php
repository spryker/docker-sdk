<?php

use Barryvdh\LaravelIdeHelper\Console\ModelsCommand;
use Illuminate\Container\Container;
use Illuminate\Filesystem\Filesystem;
use Symfony\Component\Console\Input\ArrayInput;
use Symfony\Component\Console\Output\ConsoleOutput;
use Illuminate\Database\Capsule\Manager as Capsule;

require_once __DIR__ . '/vendor/autoload.php';

function base_path($path = '') {
    return __DIR__ . '/' . $path;
}

// Database setup
$capsule = new Capsule();

$capsule->addConnection([
    'driver'   => 'sqlite',
    'database' => '/docker_sdk/data/spryker_docker_sdk.db',
    'prefix'   => '',
]);

$capsule->setAsGlobal();
$capsule->bootEloquent();


$filesystem = new Filesystem();

// Instantiate the ModelsCommand
$modelsCommand = new ModelsCommand($filesystem);

$container = new Container();

$container->singleton('db', function() use ($capsule) {
    return $capsule->getDatabaseManager();
});

$container->bind('files', function() use ($filesystem) {
    return $filesystem;
});
$container->bind('config', function() {
    return new class {
        public function get($key) {
            $arr = [
                'ide-helper.model_locations' => [
                    __DIR__ . '/src/Model',
                ],
                'ide-helper.ignored_models' => [
                    'User',
                ],
                'ide-helper.additional_relation_types' => [],
                'ide-helper.additional_relation_return_types' => [],
                'ide-helper.model_hooks' => [],
                'ide-helper.custom_db_types.sqlite' => [],
            ];
            return $arr[$key] ?? null;
        }
    };
});

$modelsCommand->setLaravel($container);

// Define input parameters for the command
$input = new ArrayInput([]);
$output = new ConsoleOutput();

// Run the command
$modelsCommand->run($input, $output);
