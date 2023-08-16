<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSDK;

use DockerSDK\Eloquent\EloquentInitializer;
use Illuminate\Container\Container;
use Illuminate\Database\Capsule\Manager;
use Symfony\Component\Yaml\Parser;
use Twig\Environment;
use Twig\Loader\ChainLoader;
use Twig\Loader\FilesystemLoader;
use Twig\TwigFilter;

class DockerSDKFactory
{
    public function getConfig(): DockerSDKConfig
    {
        return new DockerSDKConfig($this->getYmlParser());
    }

    public function getYmlParser(): Parser
    {
        return new Parser();
    }

    public function getEloquentInitializer(): EloquentInitializer
    {
        return new EloquentInitializer(
            $this->getDbManager(),
            $this->getContainer(),
            $this->getConfig()->getSqlConnectionConfig()
        );
    }

    protected function getDbManager(): Manager
    {
        return new Manager();
    }

    protected function getContainer(): Container
    {
        return new Container();
    }
}
