<?php

namespace DockerSDK\Eloquent;

use Illuminate\Container\Container;
use Illuminate\Database\Capsule\Manager;

class EloquentInitializer
{
    private Manager $manager;
    private array $sqlConnectionConfig;
    private Container $container;

    public function __construct(Manager $dbManager, Container $container, array $sqlConnectionConfig)
    {
        $this->manager = $dbManager;
        $this->container = $container;
        $this->sqlConnectionConfig = $sqlConnectionConfig;
    }

    public function init(): void
    {
        $this->manager->addConnection($this->sqlConnectionConfig);
        $this->manager->setContainer($this->container);
        $this->manager->setAsGlobal();
        $this->manager->bootEloquent();
    }
}
