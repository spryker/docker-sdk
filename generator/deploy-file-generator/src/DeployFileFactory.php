<?php

namespace DeployFileGenerator;

use DeployFileGenerator\Yaml\YamlFileLoader;
use Symfony\Component\Config\FileLocator;
use Symfony\Component\Config\FileLocatorInterface;
use Symfony\Component\Config\Loader\LoaderInterface;

class DeployFileFactory
{
    /**
     * @return LoaderInterface
     */
    public function createYamlFileLoader(): LoaderInterface
    {
        return new YamlFileLoader($this->createSymfonyFileLocator());
    }

    /**
     * @return FileLocatorInterface
     */
    public function createSymfonyFileLocator(): FileLocatorInterface
    {
        return new FileLocator();
    }

    /**
     * @return DeployFileBuilder
     */
    public function createDeployFileBuilder(): DeployFileBuilder
    {
        return new DeployFileBuilder($this->createYamlFileLoader());
    }
}
