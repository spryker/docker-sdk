<?php

namespace DeployFileGenerator\Processor;


use DeployFileGenerator\Builder\DeployFileBuilderInterface;
use DeployFileGenerator\Loader\DeployFileLoaderInterface;

class DeployFileProcessor implements DeployFileProcessorInterface
{
    /**
     * @var DeployFileLoaderInterface
     */
    private $loader;
    /**
     * @var DeployFileBuilderInterface
     */
    private $builder;

    /**
     * @param DeployFileLoaderInterface $loader
     * @param DeployFileBuilderInterface $builder
     */
    public function __construct(DeployFileLoaderInterface $loader, DeployFileBuilderInterface $builder)
    {
        $this->loader = $loader;
        $this->builder = $builder;
    }

    /**
     * @param string $currentDeployFilePath
     * @param string $outputDeployFilePath
     *
     * @return string
     */
    public function buildDeployFile(string $currentDeployFilePath, string $outputDeployFilePath): string
    {
        return $this->builder
            ->build(
                $this->loader->load($currentDeployFilePath),
                $outputDeployFilePath
            );
    }
}
