<?php

namespace DeployFileGenerator;

use Symfony\Component\Config\Loader\LoaderInterface;

class DeployFileBuilder
{
    /**
     * @var LoaderInterface
     */
    private $loader;

    /**
     * @param LoaderInterface $loader
     */
    public function __construct(LoaderInterface $loader)
    {
        $this->loader = $loader;
    }

    public function buildDeployFile(string $currentDeployFilePath): array
    {
        return $this->loader->load($currentDeployFilePath);
    }
}
