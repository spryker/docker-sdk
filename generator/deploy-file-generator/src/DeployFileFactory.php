<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator;

use DeployFileGenerator\Executor\CleanUpExecutor;
use DeployFileGenerator\Executor\ExecutorInterface;
use DeployFileGenerator\Executor\ExportDeployFileTransferToYamlExecutor;
use DeployFileGenerator\Executor\ImportBaseDataExecutor;
use DeployFileGenerator\Executor\ImportProjectDataExecutor;
use DeployFileGenerator\Executor\PrepareDeployFileTransferExecutor;
use DeployFileGenerator\Executor\SortResultDataExecutor;
use DeployFileGenerator\Executor\ValidateDeployFileExecutor;
use DeployFileGenerator\FileFinder\FileFinder;
use DeployFileGenerator\FileFinder\FileFinderInterface;
use DeployFileGenerator\Importer\DataImporter;
use DeployFileGenerator\Importer\DeployFileImporterInterface;
use DeployFileGenerator\MergeResolver\DeployFileMergeResolver;
use DeployFileGenerator\MergeResolver\MergeResolverInterface;
use DeployFileGenerator\MergeResolver\Resolvers\ServiceMergeResolver;
use DeployFileGenerator\Output\DeployFileYamlOutput;
use DeployFileGenerator\Output\OutputInterface;
use DeployFileGenerator\Output\Table\TableBuilder;
use DeployFileGenerator\Output\Table\TableBuilderInterface;
use DeployFileGenerator\Output\ValidationTableOutput;
use DeployFileGenerator\ParametersResolver\ParametersResolver;
use DeployFileGenerator\ParametersResolver\ParametersResolverInterface;
use DeployFileGenerator\ParametersResolver\Resolvers\PercentAnnotationParameterResolver;
use DeployFileGenerator\Processor\DeployFileProcessor;
use DeployFileGenerator\Processor\DeployFileProcessorInterface;
use DeployFileGenerator\Validator\ValidatorFactory;
use Symfony\Component\Yaml\Dumper;
use Symfony\Component\Yaml\Parser;

class DeployFileFactory
{
    /**
     * @return \DeployFileGenerator\Processor\DeployFileProcessorInterface
     */
    public function createDeployFileBuildProcessor(): DeployFileProcessorInterface
    {
        return new DeployFileProcessor($this->createDeployFileBuildExecutorCollection());
    }

    /**
     * @return \DeployFileGenerator\Processor\DeployFileProcessorInterface
     */
    public function createDeployFileConfigProcessor(): DeployFileProcessorInterface
    {
        return new DeployFileProcessor($this->createDeployFileConfigExecutorCollection());
    }

    /**
     * @return array<\DeployFileGenerator\Executor\ExecutorInterface>
     */
    public function createDeployFileBuildExecutorCollection(): array
    {
        return [
            $this->createPrepareDeployFileTransferExecutor(),
            $this->createProjectImportDataExecutor(),
            $this->createBaseImportDataExecutor(),
            $this->createCleanUpExecutor(),
            $this->createSortResultDataExecutor(),
            $this->createValidateDeployFileExecutor(),
            $this->createExportDeployFileTransferToYamlExecutor(),
        ];
    }

    /**
     * @return array<\DeployFileGenerator\Executor\ExecutorInterface>
     */
    public function createDeployFileConfigExecutorCollection(): array
    {
        return [
            $this->createPrepareDeployFileTransferExecutor(),
            $this->createProjectImportDataExecutor(),
            $this->createBaseImportDataExecutor(),
            $this->createCleanUpExecutor(),
            $this->createSortResultDataExecutor(),
            $this->createValidateDeployFileExecutor(),
        ];
    }

    /**
     * @return \DeployFileGenerator\Importer\DeployFileImporterInterface
     */
    public function createProjectDataImporter(): DeployFileImporterInterface
    {
        return new DataImporter(
            $this->createDeployFileConfig()->getProjectDirectoryPath(),
            $this->createSymfonyYamlParser(),
            $this->createParametersResolver(),
            $this->createDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\Importer\DeployFileImporterInterface
     */
    public function createBaseDataImporter(): DeployFileImporterInterface
    {
        return new DataImporter(
            $this->createDeployFileConfig()->getBaseDirectoryPath(),
            $this->createSymfonyYamlParser(),
            $this->createParametersResolver(),
            $this->createDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\MergeResolver\MergeResolverInterface
     */
    public function createDeployFileMergeResolver(): MergeResolverInterface
    {
        return new DeployFileMergeResolver(
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
     * @return \DeployFileGenerator\Output\OutputInterface
     */
    public function createDeployFileYamlOutput(): OutputInterface
    {
        return new DeployFileYamlOutput(
            $this->createSymfonyYamlDumper(),
            $this->createDeployFileConfig()->getYamlInline(),
        );
    }

    /**
     * @return \DeployFileGenerator\Output\OutputInterface
     */
    public function createValidationTableOutput(): OutputInterface
    {
        return new ValidationTableOutput($this->createTableBuilder());
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createPrepareDeployFileTransferExecutor(): ExecutorInterface
    {
        return new PrepareDeployFileTransferExecutor(
            $this->createSymfonyYamlParser(),
            $this->createFileFinder(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createExportDeployFileTransferToYamlExecutor(): ExecutorInterface
    {
        return new ExportDeployFileTransferToYamlExecutor(
            $this->createSymfonyYamlDumper(),
            $this->createDeployFileConfig()->getYamlInline(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createProjectImportDataExecutor(): ExecutorInterface
    {
        return new ImportProjectDataExecutor(
            $this->createProjectDataImporter(),
            $this->createDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createBaseImportDataExecutor(): ExecutorInterface
    {
        return new ImportBaseDataExecutor(
            $this->createBaseDataImporter(),
            $this->createDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createValidateDeployFileExecutor(): ExecutorInterface
    {
        return new ValidateDeployFileExecutor(
            $this->createValidatorFactory()->createValidator(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createCleanUpExecutor(): ExecutorInterface
    {
        return new CleanUpExecutor();
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createSortResultDataExecutor(): ExecutorInterface
    {
        return new SortResultDataExecutor(
            $this->createDeployFileConfig()->getDeployFileOutputOrderKeys(),
        );
    }

    /**
     * @return \DeployFileGenerator\Output\Table\TableBuilderInterface
     */
    public function createTableBuilder(): TableBuilderInterface
    {
        return new TableBuilder();
    }

    /**
     * @return \DeployFileGenerator\Validator\ValidatorFactory
     */
    protected function createValidatorFactory(): ValidatorFactory
    {
        return new ValidatorFactory();
    }
}
