<?php

use DeployFileGenerator\Command\ConfigCommand;
use Symfony\Component\Console\Application;

define('DS', DIRECTORY_SEPARATOR);
define('APPLICATION_SOURCE_DIR', __DIR__ . DS . 'src');
include_once __DIR__ . DS . '..' . DS . 'vendor' . DS . 'autoload.php';

$application = new Application();
$application->addCommands([
    new ConfigCommand(),
]);
$application->run();
