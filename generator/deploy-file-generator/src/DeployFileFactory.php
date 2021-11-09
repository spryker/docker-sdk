<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator;

use DeployFileGenerator\Builder\DeployFileBuilder;
use DeployFileGenerator\Builder\DeployFileBuilderInterface;
use DeployFileGenerator\Executor\ExecutorFactory;
use DeployFileGenerator\FileFinder\FileFinder;
use DeployFileGenerator\FileFinder\FileFinderInterface;
use DeployFileGenerator\Importer\DeployFileImporterInterface;
use DeployFileGenerator\Importer\YamlDataImporter;
use DeployFileGenerator\MergeResolver\MergeResolverInterface;
use DeployFileGenerator\MergeResolver\Resolvers\ServiceMergeResolver;
use DeployFileGenerator\MergeResolver\YamlDeployFileMergeResolver;
use DeployFileGenerator\ParametersResolver\ParametersResolver;
use DeployFileGenerator\ParametersResolver\ParametersResolverInterface;
use DeployFileGenerator\ParametersResolver\Resolvers\PercentAnnotationParameterResolver;
use DeployFileGenerator\Processor\DeployFileProcessor;
use DeployFileGenerator\Processor\DeployFileProcessorInterface;
use DeployFileGenerator\Strategy\DeployFileBuildStrategyInterface;
use DeployFileGenerator\Strategy\YamlDeployFileBuildStrategy;
use Symfony\Component\Yaml\Dumper;
use Symfony\Component\Yaml\Parser;

class DeployFileFactory
{
    /**
     * @return \DeployFileGenerator\Builder\DeployFileBuilderInterface
     */
    public function createDeployFileBuilder(): DeployFileBuilderInterface
    {
        return new DeployFileBuilder(
            $this->createYamlDeployFileProcessor(),
        );
    }

    /**
     * @return \DeployFileGenerator\Processor\DeployFileProcessorInterface
     */
    public function createYamlDeployFileProcessor(): DeployFileProcessorInterface
    {
        return new DeployFileProcessor(
            $this->createYamlDeployFileBuildStrategy(),
        );
    }

    /**
     * @return \DeployFileGenerator\Strategy\DeployFileBuildStrategyInterface
     */
    public function createYamlDeployFileBuildStrategy(): DeployFileBuildStrategyInterface
    {
        return new YamlDeployFileBuildStrategy(
            $this->createExecutorFactory()->createYamlDeployFileBuildExecutorCollection(),
        );
    }

    /**
     * @return \DeployFileGenerator\Importer\DeployFileImporterInterface
     */
    public function createYamlProjectDataImporter(): DeployFileImporterInterface
    {
        return new YamlDataImporter(
            $this->createDeployFileConfig()->getProjectDirectoryPath(),
            $this->createSymfonyYamlParser(),
            $this->createParametersResolver(),
            $this->createYamlDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\Importer\DeployFileImporterInterface
     */
    public function createYamlBaseDataImporter(): DeployFileImporterInterface
    {
        return new YamlDataImporter(
            $this->createDeployFileConfig()->getBaseDirectoryPath(),
            $this->createSymfonyYamlParser(),
            $this->createParametersResolver(),
            $this->createYamlDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\MergeResolver\MergeResolverInterface
     */
    public function createYamlDeployFileMergeResolver(): MergeResolverInterface
    {
        return new YamlDeployFileMergeResolver(
            $this->getMergeResolverCollection(),
        );
    }

    /**
     * @return array<\DeployFileGenerator\MergeResolver\MergeResolverInterface>
     */
    public function getMergeResolverCollection(): array
    {
        return [
            new ServiceMergeResolver(),
        ];
    }

    /**
     * @return \DeployFileGenerator\DeployFileConfig
     */
    public function createDeployFileConfig(): DeployFileConfig
    {
        return new DeployFileConfig();
    }

    /**
     * @return \DeployFileGenerator\ParametersResolver\ParametersResolverInterface
     */
    public function createParametersResolver(): ParametersResolverInterface
    {
        return new ParametersResolver(
            $this->getParameterResolverCollection(),
        );
    }

    /**
     * @return array<\DeployFileGenerator\ParametersResolver\Resolvers\ParameterResolverInterface>
     */
    public function getParameterResolverCollection(): array
    {
        return [
            new PercentAnnotationParameterResolver(),
        ];
    }

    /**
     * @return \DeployFileGenerator\FileFinder\FileFinderInterface
     */
    public function createFileFinder(): FileFinderInterface
    {
        return new FileFinder($this->createDeployFileConfig());
    }

    /**
     * @return \Symfony\Component\Yaml\Parser
     */
    public function createSymfonyYamlParser(): Parser
    {
        return new Parser();
    }

    /**
     * @return \Symfony\Component\Yaml\Dumper
     */
    public function createSymfonyYamlDumper(): Dumper
    {
        return new Dumper();
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorFactory
     */
    public function createExecutorFactory(): ExecutorFactory
    {
        return new ExecutorFactory($this);
    }
}
