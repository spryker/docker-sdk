<?php

namespace DeployFileGenerator;

use DeployFileGenerator\Builder\DeployFileBuilderInterface;
use DeployFileGenerator\Builder\YamlDeployFileBuilder;
use DeployFileGenerator\Loader\DeployFileLoaderInterface;
use DeployFileGenerator\Loader\YamlDeployFileLoader;
use DeployFileGenerator\ParameterResolver\ParametersResolver;
use DeployFileGenerator\ParameterResolver\ParametersResolverInterface;
use DeployFileGenerator\ParameterResolver\Resolvers\PercentAnnotationParameterResolver;
use DeployFileGenerator\Processor\DeployFileProcessor;
use DeployFileGenerator\Processor\DeployFileProcessorInterface;
use Symfony\Component\Yaml\Dumper;
use Symfony\Component\Yaml\Parser;

class DeployFileFactory
{
    /**
     * @return DeployFileLoaderInterface
     */
    public function createYamlFileLoader(): DeployFileLoaderInterface
    {
        return new YamlDeployFileLoader(
            $this->createSymfonyYamlParser(),
            $this->createParametersResolver(),
            $this->createDeployFileConfig()
        );
    }

    /**
     * @return DeployFileProcessorInterface
     */
    public function createDeployFileProcessor(): DeployFileProcessorInterface
    {
        return new DeployFileProcessor(
            $this->createYamlFileLoader(),
            $this->createYamlBuilder()
        );
    }

    /**
     * @return DeployFileConfig
     */
    public function createDeployFileConfig(): DeployFileConfig
    {
        return new DeployFileConfig();
    }

    /**
     * @return ParametersResolverInterface
     */
    public function createParametersResolver(): ParametersResolverInterface
    {
        return new ParametersResolver(
            $this->getParameterResolverCollection()
        );
    }

    /**
     * @return PercentAnnotationParameterResolver[]
     */
    public function getParameterResolverCollection(): array
    {
        return [
            new PercentAnnotationParameterResolver(),
        ];
    }

    public function createYamlBuilder(): DeployFileBuilderInterface
    {
        return new YamlDeployFileBuilder(
            $this->createSymfonyYamlDumper(),
            $this->createDeployFileConfig()->getYamlInline()
        );
    }

    /**
     * @return Parser
     */
    public function createSymfonyYamlParser(): Parser
    {
        return new Parser();
    }

    /**
     * @return Dumper
     */
    public function createSymfonyYamlDumper(): Dumper
    {
        return new Dumper();
    }
}
