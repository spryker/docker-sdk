<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator;

use DeployFileGenerator\FileFinder\FileFinder;
use DeployFileGenerator\FileFinder\FileFinderInterface;
use DeployFileGenerator\Importer\DataImporter;
use DeployFileGenerator\Importer\DeployFileImporterInterface;
use DeployFileGenerator\MergeResolver\DeployFileMergeResolver;
use DeployFileGenerator\MergeResolver\MergeResolverInterface;
use DeployFileGenerator\MergeResolver\Resolvers\ServiceMergeResolver;
use DeployFileGenerator\Output\DeployFileOutput;
use DeployFileGenerator\Output\OutputInterface;
use DeployFileGenerator\ParameterFilter\Filters\LowerCaseParameterFilter;
use DeployFileGenerator\ParameterFilter\Filters\UpperCaseParameterFilter;
use DeployFileGenerator\ParameterFilter\ParameterFilterInterface;
use DeployFileGenerator\ParametersResolver\ParametersResolver;
use DeployFileGenerator\ParametersResolver\ParametersResolverInterface;
use DeployFileGenerator\ParametersResolver\Resolvers\PercentAnnotationParameterResolver;
use DeployFileGenerator\Processor\DeployFileProcessor;
use DeployFileGenerator\Processor\DeployFileProcessorInterface;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Processor\Executor\Executors\ImportBaseDataExecutor;
use DeployFileGenerator\Processor\Executor\Executors\ImportProjectDataExecutor;
use DeployFileGenerator\Processor\Executor\PostExecutors\CleanImportsExecutor;
use DeployFileGenerator\Processor\Executor\PostExecutors\CleanServicesExecutor;
use DeployFileGenerator\Processor\Executor\PostExecutors\ExportDeployFileTransferToYamlExecutor;
use DeployFileGenerator\Processor\Executor\PostExecutors\SortResultDataExecutor;
use DeployFileGenerator\Processor\Executor\PostExecutors\ValidateDeployFileExecutor;
use DeployFileGenerator\Processor\Executor\PreExecutors\PrepareDeployFileTransferExecutor;
use DeployFileGenerator\Validator\DeployFileValidatorFactory;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Console\Output\OutputInterface as SymfonyOutputInterface;
use Symfony\Component\Yaml\Dumper;
use Symfony\Component\Yaml\Parser;

class DeployFileGeneratorFactory
{
    /**
     * @return \DeployFileGenerator\Processor\DeployFileProcessorInterface
     */
    public function createDeployFileBuildProcessor(): DeployFileProcessorInterface
    {
        return (new DeployFileProcessor())
            ->addPreExecutor($this->createPrepareDeployFileTransferExecutor())
            ->addExecutor($this->createProjectImportDataExecutor())
            ->addExecutor($this->createBaseImportDataExecutor())
            ->addPostExecutor($this->createCleanImportsExecutor())
            ->addPostExecutor($this->createCleanServicesExecutor())
            ->addPostExecutor($this->createSortResultDataExecutor())
            ->addPostExecutor($this->createValidateDeployFileExecutor())
            ->addPostExecutor($this->createExportDeployFileTransferToYamlExecutor());
    }

    /**
     * @return \DeployFileGenerator\Processor\DeployFileProcessorInterface
     */
    public function createDeployFileConfigProcessor(): DeployFileProcessorInterface
    {
        return (new DeployFileProcessor())
            ->addPreExecutor($this->createPrepareDeployFileTransferExecutor())
            ->addExecutor($this->createProjectImportDataExecutor())
            ->addExecutor($this->createBaseImportDataExecutor())
            ->addPostExecutor($this->createCleanImportsExecutor())
            ->addPostExecutor($this->createCleanServicesExecutor())
            ->addPostExecutor($this->createSortResultDataExecutor())
            ->addPostExecutor($this->createValidateDeployFileExecutor());
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
     * @return \DeployFileGenerator\DeployFileGeneratorConfig
     */
    public function createDeployFileConfig(): DeployFileGeneratorConfig
    {
        return new DeployFileGeneratorConfig();
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
            new PercentAnnotationParameterResolver([
                $this->createLowerCaseParameterFilter(),
                $this->createUpperCaseParameterFilter(),
            ]),
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
    public function createDeployFileOutput(): OutputInterface
    {
        return new DeployFileOutput(
            $this->createSymfonyConsoleOutput(),
            $this->createSymfonyYamlDumper(),
            $this->createDeployFileConfig(),
        );
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    public function createPrepareDeployFileTransferExecutor(): ExecutorInterface
    {
        return new PrepareDeployFileTransferExecutor(
            $this->createSymfonyYamlParser(),
            $this->createFileFinder(),
        );
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    public function createExportDeployFileTransferToYamlExecutor(): ExecutorInterface
    {
        return new ExportDeployFileTransferToYamlExecutor(
            $this->createSymfonyYamlDumper(),
            $this->createDeployFileConfig(),
        );
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    public function createProjectImportDataExecutor(): ExecutorInterface
    {
        return new ImportProjectDataExecutor(
            $this->createProjectDataImporter(),
            $this->createDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    public function createBaseImportDataExecutor(): ExecutorInterface
    {
        return new ImportBaseDataExecutor(
            $this->createBaseDataImporter(),
            $this->createDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    public function createValidateDeployFileExecutor(): ExecutorInterface
    {
        return new ValidateDeployFileExecutor(
            $this->createDeployFileValidatorFactory()->createDeployFileValidator(),
        );
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    public function createSortResultDataExecutor(): ExecutorInterface
    {
        return new SortResultDataExecutor(
            $this->createDeployFileConfig(),
        );
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    public function createCleanImportsExecutor(): ExecutorInterface
    {
        return new CleanImportsExecutor();
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    public function createCleanServicesExecutor(): ExecutorInterface
    {
        return new CleanServicesExecutor();
    }

    /**
     * @return \DeployFileGenerator\Validator\DeployFileValidatorFactory
     */
    protected function createDeployFileValidatorFactory(): DeployFileValidatorFactory
    {
        return new DeployFileValidatorFactory();
    }

    /**
     * @return \Symfony\Component\Console\Output\OutputInterface
     */
    protected function createSymfonyConsoleOutput(): SymfonyOutputInterface
    {
        return new ConsoleOutput();
    }

    /**
     * @return \DeployFileGenerator\ParameterFilter\ParameterFilterInterface
     */
    public function createLowerCaseParameterFilter(): ParameterFilterInterface
    {
        return new LowerCaseParameterFilter();
    }

    /**
     * @return \DeployFileGenerator\ParameterFilter\ParameterFilterInterface
     */
    public function createUpperCaseParameterFilter(): ParameterFilterInterface
    {
        return new UpperCaseParameterFilter();
    }
}
