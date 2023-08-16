<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace SharedServices;

use DockerSDK\DockerSDKFactory;
use Twig\Environment;
use Twig\Loader\ChainLoader;
use Twig\Loader\FilesystemLoader;

class SharedServicesFactory extends DockerSDKFactory
{
    public function getConfig(): SharedServicesConfig
    {
        return new SharedServicesConfig($this->getYmlParser());
    }

    public function getTwig(): Environment
    {
//        todo: move to DockerSDKFactory and make abstract
        $loaders = new ChainLoader([
            new FilesystemLoader($this->getConfig()->getTemplatesPath()),
        ]);

        return new Environment($loaders);
    }
}
